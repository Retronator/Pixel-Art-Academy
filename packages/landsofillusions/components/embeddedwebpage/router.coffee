AE = Artificial.Everywhere
AB = Artificial.Base
LOI = LandsOfIllusions

class LOI.Components.EmbeddedWebpage.Router
  constructor: (@embeddedWebpage, @urlField) ->
    @currentRouteData = new ReactiveField null

    # Minimize reactivity by isolating different parts of the route.
    @currentParameters = new ComputedField =>
      @currentRouteData()?.parameters
    ,
      EJSON.equals
    ,
      true

    @currentRoute = new ComputedField =>
      @currentRouteData()?.route
    ,
      (a, b) => a is b
    ,
      true

    @currentRouteName = new ComputedField =>
      @currentRoute()?.name
    ,
      true

    @currentRoutePath = new ComputedField =>
      @currentRouteData()?.path
    ,
      true

    # Update route data based on the URL.
    @_urlUpdateAutorun = Tracker.autorun (computation) =>
      url = new URL @urlField()

      host = url.hostname
      path = url.pathname
      searchParameters = url.searchParams

      {route, matchData} = AB.Router.findRoute host, path

      if matchData
        currentRouteData = _.extend {route, path, host, searchParameters}, matchData
        @currentRouteData currentRouteData

      else
        @currentRouteData null

  destroy: ->
    @currentParameters.stop()
    @currentRoute.stop()
    @currentRouteName.stop()
    @currentRoutePath.stop()
    @_urlUpdateAutorun.stop()

  getParameter: (parameter) ->
    @currentParameters()[parameter]

  setParameter: (parameter, value) ->
    # We need to clone the parameters before we change them, since otherwise we'd be
    # changing the original with which the computed field will compare the new array.
    parameters = _.clone @currentParameters()
    parameters[parameter] = value
    @setParameters parameters

  setParameters: (parameters) ->
    @goToRoute @currentRouteName(), parameters

  goToRoute: (routeName, parameters, options = {}) ->
    # Find the URL for this route.
    return unless url = AB.Router.createUrl routeName, parameters

    @goToUrl url, options

  goToUrl: (url, options = {}) ->
    @urlField url, options
