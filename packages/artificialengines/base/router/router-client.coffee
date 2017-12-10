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

  @createPath: (routeName, parameters) ->
    return unless route = @routes[routeName]

    try
      route.createPath(parameters) or '/'

    catch error
      null

  @getParameter: (parameter) ->
    @currentParameters()[parameter]

  @setParameters: (parameters) ->
    @goToRoute @currentRouteName(), parameters
    
  @goToRoute: (routeName, parameters) ->
    return unless path = @createPath routeName, parameters
    history.pushState {}, null, path
    @onHashChange()

  @initialize: ->
    # React to URL changes.
    $(window).on 'hashchange', => @onHashChange()

    # Process URL for the first time.
    @onHashChange()

    # Hijack link clicks.
    $('body').on 'click', 'a', (event) =>
      link = event.target

      {route} = @findRoute link.hostname, link.pathname

      if route
        # This link leads to one of our routes so go there manually.
        event.preventDefault()
        history.pushState {}, null, link.pathname
        @onHashChange()

  @renderRoot: (parentComponent) ->
    return null unless currentRoute = @currentRoute()

    @_previousRoute = currentRoute

    # We instantiate the page so that we can send the instance to the Render component. If it was just a class, it
    # would treat it as a function and try to execute it instead of pass it as the context to the Render component.
    layoutData =
      page: new currentRoute.componentClass

    new Blaze.Template =>
      Blaze.With layoutData, =>
        currentRoute.layoutClass.renderComponent parentComponent

  @findRoute: (host, path) ->
    # Find the route that matches our location.
    for name, route of @routes
      matchData = route.match host, path
      return {route, matchData} if matchData

    null

  @onHashChange: ->
    host = location.hostname
    path = location.pathname

    {route, matchData} = @findRoute host, path

    if matchData
      currentRoute = _.extend {route, path, host}, matchData
      @currentRouteData currentRoute
      
    else
      # Try to find a 404 route for the host.
      for name, route of @error404Routes
        if route.match host
          @currentRouteData {route, path, host, error404: true}
          return

      @currentRouteData null

  # Dynamically update window title based on the current route.
  @updateWindowTitle: (route, routeParameters) ->
    # Determine the new title.
    title = null

    # Call layout first and component later so it can override the more general layout results.
    for target in [route.layoutClass, route.componentClass]
      result = target.title? routeParameters

      # Only override the parameter if we get a result.
      title = result if result

    document.title = title if title
