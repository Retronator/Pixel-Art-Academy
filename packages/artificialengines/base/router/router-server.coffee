AB = Artificial.Base

queryString = require 'querystring'

class AB.Router extends AB.Router
  _requestHost = null
  _absoluteUrl = null

  @initialize: ->
    WebApp.rawConnectHandlers.use (request, response, next) =>
      # HACK: Use response as the carrier for host, so we can extract it later in OAuth flow.
      response._requestHost = request.headers.host

      next()

    # HACK: Override Oauth request handlers.
    for name, handler of OAuth._requestHandlers
      do (handler) ->
        OAuth._requestHandlers[name] = (service, query, response) ->
          _requestHost = response._requestHost

          try
            # Call the original handler. We expect it will call absolute URL at some point.
            handler arguments...

          catch exception
            console.error "Exception in OAuth flow", exception

          finally
            _requestHost = null

    # HACK: Override absolute URL function to use the request host as the root url.
    _absoluteUrl = Meteor.absoluteUrl
    Meteor.absoluteUrl = (path, options) ->
      # Absolute URL doesn't remove the leading slash, so we do it to allow both relative and server-relative URLs.
      path = path.substring 1 if path?[0] is '/'
      
      if _requestHost
        # We reuse the protocol from the root url.
        rootUrl = _absoluteUrl()
        protocol = rootUrl.match(/(.*:\/\/).*/)[1]

        # We strip the localhost part and port since that would be added by the proxy in production to address
        # the node server behind the proxy, but we need the redirect URI's to point to the proxy.
        requestHost = _requestHost.match(/(?:localhost\.)?([^:]*)(?::.*)?/)[1]

        rootUrl = "#{protocol}#{requestHost}"

        options ?= {}
        options.rootUrl = rootUrl

      _absoluteUrl path, options

    # Also copy its extra data.
    Meteor.absoluteUrl[key] = value for own key, value of _absoluteUrl

    WebApp.connectHandlers.use (request, response, next) =>
      if request.method is 'POST'
        body = ''

        # Receive the body of the post message.
        request.on 'data', Meteor.bindEnvironment (data) =>
          body += data

          # Kill connection if the body becomes too big
          if body.length > 1e6
            body = null
            response.writeHead(413, 'Content-Type': 'text/plain')
            response.end()
            request.connection.destroy()

        request.on 'end', Meteor.bindEnvironment =>
          # Cancel if body was not loaded.
          return unless body

          # Parse post data from the body.
          switch request.headers['content-type']
            when 'application/json'
              try
                postData = JSON.parse body

            when 'application/x-www-form-urlencoded'
              postData = queryString.parse body

          # Attach post data to request for further processors.
          request.postData = postData

          # If login token was sent, include it in the head.
          if postData?.loginToken
            script = "<script>window._meteorLoginToken = '#{postData.loginToken}';</script>"
            Inject.rawHead 'Artificial.Base.Router', script, response

          next()

        return

      path = request.url

      # Get the host without the port.
      host = request.headers.host.match(/[^:]*/)[0]

      # Find the route that will handle this request.
      {route, matchData} = @findRoute host, path

      unless route
        next()
        return

      # We found a route for this URL, so write extra things to head.
      routeParameters = matchData.parameters

      head = {}

      # Call layout first and component later so it can override the more general layout results.
      for target in [route.layoutClass, route.pageClass]
        # Go over values that need escaping.
        for headParameter in ['title', 'description', 'image', 'viewport', 'touchIcon']
          # Only override the parameter if we get a result.
          result = target[headParameter]? routeParameters

          # We need to escape the string since we'll be inserting it into html response.
          head[headParameter] = _.escape result if result

        # Gather the rest of the values without escaping.
        for headParameter in ['webApp']
          result = target[headParameter]? routeParameters
          head[headParameter] = result if result?

      # Set the head.
      headHtml = ""

      if head.title
        headHtml += "<title>#{head.title}</title>\n"
        headHtml += "<meta property='og:title' content='#{head.title}' />\n"

      if head.description
        headHtml += "<meta name='description' content='#{head.description}' />\n"
        headHtml += "<meta property='og:description' content='#{head.description}' />\n"

      if head.image
        headHtml += "<meta property='og:image' content='#{head.image}' />\n"

      if head.viewport
        headHtml += "<meta name='viewport' content='#{head.viewport}' />\n"

      if head.touchIcon
        headHtml += "<link rel='apple-touch-icon' href='#{head.touchIcon}' />\n"
        
      if head.webApp
        headHtml += "<meta name='apple-mobile-web-app-capable' content='yes' />\n"

      # Build a canonical URL by replacing parameters in the url.
      canonicalUrl = route.path
      
      for parameterName, parameter of routeParameters
        # Parameter starts with a colon and could end with a question mark. Question mark literal needs to be escaped
        # in a regex, so we want to have \? in the regex, but to put a backslash in a javascript string, we need to
        # escape the backslash too, giving us \\?. The final regex questions mark matches the literal questions mark
        # 0 to 1 times.
        parameterRegex = new RegExp ":#{parameterName}\\??", 'g'
        canonicalUrl = canonicalUrl.replace parameterRegex, parameter or ''

      # Trim leading and ending slashes (that could result when removing parameters).
      canonicalUrl = _.trim canonicalUrl, '/'

      # Unless the URL is now empty, re-add the leading slash.
      canonicalUrl = "/#{canonicalUrl}" if canonicalUrl

      # We build the absolute cannonical URL, by reusing the protocol from the root url.
      rootUrl = Meteor.absoluteUrl()
      protocol = rootUrl.match(/(.*:\/\/).*/)[1]

      # Host might not be set on the route (if it's universal) so reuse the one from the request.
      host = route.host or request.headers.host

      canonicalUrl = "#{protocol}#{host}#{canonicalUrl}"
      headHtml += "<meta property='og:url' content='#{canonicalUrl}' />\n"

      Inject.rawHead 'Artificial.Base.Router', headHtml, response

      next()

  @createUrl: (routeName, parameters) ->
    # Allow sending components directly.
    routeName = routeName.componentName() if routeName.componentName

    return unless route = @routes[routeName]

    try
      path = route.createPath(parameters) or '/'

    catch error
      # Errors are common because we often have missing parameters when data is loading.
      # We just return null as the function will re-run when new parameters get available.
      return null

    host = route.host

    # No need for a slash if we're changing the host to its main page.
    path = '' if path is '/'

    # We always assume https on the server and return the full URL with host.
    "https://#{host}#{path}"
