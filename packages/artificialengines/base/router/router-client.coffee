AB = Artificial.Base

class AB.Router extends AB.Router
  @currentRouteData = new ReactiveField null

  # Minimize reactivity by isolating different parts of the route.
  @currentParameters = new ComputedField =>
    @currentRouteData()?.parameters
  ,
    EJSON.equals

  @currentRoute = new ComputedField =>
    @currentRouteData()?.route
  ,
    (a, b) => a is b

  @currentRouteName = new ComputedField =>
    @currentRoute()?.name

  @currentRoutePath = new ComputedField =>
    @currentRouteData()?.path

  @getParameter: (parameter) ->
    @currentParameters()[parameter]

  @setParameters: (parameters) ->
    @goToRoute @currentRouteName(), parameters

  @createUrl: (routeName, parameters) ->
    return unless route = @routes[routeName]

    try
      path = route.createPath(parameters) or '/'

    catch error
      # Errors are common because we often have missing parameters when data is loading.
      # We just return null as the function will re-run when new parameters get available.
      return null

    # See if we need to change hosts.
    currentHost = @currentRoute().host

    if route.host isnt currentHost
      host = route.host

      # Keep the current protocol and port.
      protocol = location.protocol
      port = ":#{location.port}" if location.port

      # Keep the localhost prefix.
      host = "localhost.#{host}" if _.startsWith location.hostname, 'localhost'

      # No need for a slash if we're changing the host to its main page.
      path = '' if path is '/'

      path = "#{protocol}//#{host}#{port}#{path}"

    # Return generated path.
    path

  @goToRoute: (routeName, parameters, options = {}) ->
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

  @initialize: ->
    # HACK: Override absolute URL function to use the browser origin as the root url.
    _absoluteUrl = Meteor.absoluteUrl
    Meteor.absoluteUrl = (path, options) ->
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

      # Only do soft link changes when we're staying within the same host.
      if link.hostname is location.hostname
        event.preventDefault()
        history.pushState {}, null, link.pathname
        @onPathChange()

        # Scroll to top since we expect that to happen if this was a hard link.
        $(document).scrollTop(0)

  @renderRoot: (parentComponent) ->
    return null unless currentRoute = @currentRoute()

    @_previousRoute = currentRoute

    # We instantiate the page so that we can send the instance to the Render component. If it was just a class, it
    # would treat it as a function and try to execute it instead of pass it as the context to the Render component.
    layoutData =
      page: new currentRoute.pageClass

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
