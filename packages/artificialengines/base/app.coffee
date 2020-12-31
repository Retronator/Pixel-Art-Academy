AB = Artificial.Base
AC = Artificial.Control
AM = Artificial.Mirage

# The root class from which to inherit your custom app.
class AB.App extends AM.Component
  @register 'Artificial.Base.App'

  template: ->
    'Artificial.Base.App'

  constructor: ->
    super arguments...

    @appTime = new ReactiveField
      elapsedAppTime: 0
      totalAppTime: 0

    if Meteor.isClient
      AM.Window.initialize()
      AC.Keyboard.initialize()

  onCreated: ->
    super arguments...

    @run()

  onDestroyed: ->
    super arguments...

    @endRun()

  appRoot: ->
    AB.Router.renderPageComponent @

  run: ->
    # Start update/draw loop.
    window.requestAnimationFrame (timestamp) =>
      @tick timestamp

    # Listen for beforeunload so we can react to application closing.
    window.addEventListener 'beforeunload', (event) =>
      @endRun()

    # Dynamically update window title based on the current route.
    @autorun (computation) =>
      return unless routeData = AB.Router.currentRouteData()
      route = routeData.route

      # Determine the new title.
      title = null

      # Call layout first and component later so it can override the more general layout results.
      for target in [route.layoutClass, route.pageClass, AB.Router.currentPageComponent()]
        # Only override the parameter if we get a result.
        result = target?.title? routeData.parameters
        title = result if result

      document.title = title if title

  tick: (currentFrameTime) ->
    @lastFrameTime ?= currentFrameTime
    elapsedTime = (currentFrameTime - @lastFrameTime) / 1000
    @lastFrameTime = currentFrameTime

    # Bound elapsed time to 1 FPS.
    elapsedTime = Math.min 1, elapsedTime

    # console.log "Tick at #{Math.round 1/elapsedTime} FPS"

    appTime =
      elapsedAppTime: elapsedTime
      totalAppTime: @appTime().totalAppTime + elapsedTime

    @update appTime

    if @beginDraw()
      @draw appTime
      @endDraw()

    # Update app time reactive field last to trigger any autoruns that need to be run on app time change.
    @appTime appTime

    # Request next tick.
    window.requestAnimationFrame (timestamp) =>
      @tick timestamp

  update: (appTime) ->

  beginDraw: ->
    true

  draw: (appTime) ->

  endDraw: ->

  endRun: ->
