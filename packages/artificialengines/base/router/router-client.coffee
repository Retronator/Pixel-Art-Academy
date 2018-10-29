AB = Artificial.Base

class AB.Router extends AB.Router
  @currentRouteData = new ReactiveField null

  # Minimize reactivity by isolating different parts of the route.
  @currentParameters = new ComputedField @currentParameters, EJSON.equals
  @currentParameters: =>
    @currentRouteData()?.parameters

  @currentRoute = new ComputedField @currentRoute, (a, b) => a is b
  @currentRoute: =>
    @currentRouteData()?.route

  @currentRouteName = new ComputedField @currentRouteName
  @currentRouteName: =>
    @currentRoute()?.name

  @currentRoutePath = new ComputedField @currentRoutePath
  @currentRoutePath: =>
    @currentRouteData()?.path

  @getParameter: (parameter) ->
    @currentParameters()[parameter]

  @setParameter: (parameter, value) ->
    # We need to clone the parameters before we change them, since otherwise we'd be 
    # changing the original with which  the computed field will compare the new array.
    parameters = _.clone @currentParameters()
    parameters[parameter] = value
    @setParameters parameters

  @setParameters: (parameters) ->
    @goToRoute @currentRouteName(), parameters

  @createUrl: (routeName, parameters, options = {}) ->
    # Allow sending components directly.
    routeName = routeName.componentName() if routeName.componentName

    return unless route = @routes[routeName]

    try
      path = route.createPath(parameters) or '/'

    catch error
      # Errors are common because we often have missing parameters when data is loading.
      # We just return null as the function will re-run when new parameters get available.
      return null

    # See if we need to change hosts. If route host is not defined, it will work with any host.
    return path unless route.host or options.absolute

    # If we're already at the correct host, we also just need to change path.
    return path if route.host is @currentRoute().host and not options.absolute

    # Build a full URL.
    host = route.host or @currentRoute().host

    # Keep the current protocol and port.
    protocol = location.protocol
    port = if location.port then ":#{location.port}" else ''

    # Keep the localhost prefix.
    host = "localhost.#{host}" if _.startsWith location.hostname, 'localhost'

    # No need for a slash if we're changing the host to its main page.
    path = '' if path is '/'

    "#{protocol}//#{host}#{port}#{path}"

  @goToRoute: (routeName, parameters, options = {}) ->
    # Find the URL for this route.
    return unless url = @createUrl routeName, parameters
    
    @goToUrl url, options
    
  @goToUrl: (url, options = {}) ->
    # By default changing routes gets written to browser history.
    options.createHistory ?= true

    [match, host, path] = url.match /(.*?)(\/.*)/

    if host
      # Since the host changed, we can't use pushState. Do a hard url change.
      window.location = url

    else
      # We're staying on the current host, so we can do a soft url change.
      historyFunction = if options.createHistory then 'pushState' else 'replaceState'

      history[historyFunction] {}, null, path
      @onPathChange()

  @postToUrl: (url, parameters) ->
    $form = $("<form method='post' action='#{url}'>")

    for name, value of parameters
      $field = $("<input name='#{name}' value='#{value}'/>")
      $form.append($field)

    $('body').append($form)
    $form.submit()

  @initialize: ->
    # Log in user if token was sent using POST data.
    Meteor.loginWithToken window._meteorLoginToken if window._meteorLoginToken

    # Automatically instantiate the current page.
    @currentPageComponent = new ComputedField =>
      return null unless currentRoute = @currentRoute()

      new currentRoute.pageClass

    # HACK: Override absolute URL function to use the browser origin as the root url.
    _absoluteUrl = Meteor.absoluteUrl
    Meteor.absoluteUrl = (path, options) ->
      # Absolute URL doesn't remove the leading slash, so we do it to allow both relative and server-relative URLs.
      path = path.substring 1 if path?[0] is '/'

      # Just in case, we only want to replace the origin if options didn't do any changes to it.
      rootUrl = _absoluteUrl()
      url = _absoluteUrl path, options

      rootOrigin = rootUrl.match(/(.*:\/\/.*?)\//)[1]
      urlOrigin = rootUrl.match(/(.*:\/\/.*?)\//)[1]

      finalUrl = url.replace urlOrigin, location.origin if (rootOrigin is urlOrigin)
      finalUrl
    
    # Also copy its extra data.
    Meteor.absoluteUrl[key] = value for own key, value of _absoluteUrl
      
    # React to URL changes.
    $window = $(window)
    $window.on 'hashchange', => @onPathChange()
    $window.on 'popstate', => @onPathChange()

    # Process URL for the first time.
    @onPathChange()

    # Hijack link clicks.
    $('body').on 'click', 'a', (event) =>
      # Do not react if modifier keys are present (the user might be trying to open the link in a new tab).
      return if event.metaKey or event.ctrlKey or event.shiftKey

      link = event.currentTarget

      # Do not act on download links.
      return if link.download

      # Do not act on pure hashtag links.
      return if _.startsWith $(link).attr('href'), '#'

      # Only do soft link changes when we're staying within the same host.
      if link.hostname is location.hostname
        event.preventDefault()
        history.pushState {}, null, link.pathname
        @onPathChange()

        # Scroll to top since we expect that to happen if this was a hard link.
        $(document).scrollTop(0)

  @renderPageComponent: (parentComponent) ->
    return null unless currentRoute = @currentRoute()
    return null unless currentPageComponent = @currentPageComponent()

    layoutData =
      page: currentPageComponent

    new Blaze.Template =>
      Blaze.With layoutData, =>
        currentRoute.layoutClass.renderComponent parentComponent

  @onPathChange: ->
    host = location.hostname
    path = location.pathname

    {route, matchData} = @findRoute host, path

    if matchData
      currentRouteData = _.extend {route, path, host}, matchData
      @currentRouteData currentRouteData

    else
      @currentRouteData null

  # Dynamically update window title based on the current route.
  @updateWindowTitle: (route, routeParameters) ->
    # Determine the new title.
    title = null

    # Call layout first and component later so it can override the more general layout results.
    for target in [route.layoutClass, route.pageClass]
      result = target.title? routeParameters

      # Only override the parameter if we get a result.
      title = result if result

    document.title = title if title
