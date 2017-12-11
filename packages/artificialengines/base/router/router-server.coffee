AB = Artificial.Base

class AB.Router extends AB.Router
  @initialize: ->
    WebApp.connectHandlers.use (request, response, next) =>
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
        for headParameter in ['title', 'description', 'image']
          # Only override the parameter if we get a result.
          result = target[headParameter]? routeParameters

          # We need to escape the string since we'll be inserting it into html response.
          head[headParameter] = _.escape result if result

      # Set the head.
      headHtml = ""

      if head.title
        headHtml += "<title>#{head.title}</title>\n"
        headHtml += "<meta property='og:title' content='#{head.title}' />\n"

      if head.description
        headHtml += "<meta name='description' content='#{head.description}'>\n"
        headHtml += "<meta property='og:description' content='#{head.description}' />\n"

      if head.image
        headHtml += "<meta property='og:image' content='#{head.image}' />\n"

      # Build a cannonical URL by replacing parameters in the url.
      canonicalUrl = route.url

      for parameterName, parameter of routeParameters
        # Parameter starts with a colon and could end with a question mark. Question mark literal needs to be escaped
        # in a regex, so we want to have \? in the regex, but to put a backslash in a javascript string, we need to
        # escape the backslash too, giving us \\?. The final regex questions mark matches the literal questions mark
        # 0 to 1 times.
        parameterRegex = new RegExp ":#{parameterName}\\??", 'g'
        canonicalUrl = canonicalUrl.replace parameterRegex, parameter or ''

      # Trim leading and ending slashes (that could result when removing parameters).
      canonicalUrl = _.trim canonicalUrl, '/'

      # TODO: Handle different domains.
      absoluteUrl = Meteor.absoluteUrl canonicalUrl

      headHtml += "<meta property='og:url' content='#{absoluteUrl}' />\n"

      Inject.rawHead 'Artificial.Base.Router', headHtml, response

      next()
