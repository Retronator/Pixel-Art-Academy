AB = Artificial.Base
AC = Artificial.Control
AM = Artificial.Mirage

class AB.App extends AM.Component
  @register 'Artificial.Base.App'

  template: ->
    'Artificial.Base.App'

  constructor: ->
    @appTime = new ReactiveField
      elapsedAppTime: 0
      totalAppTime: 0

    @services = new AB.Services()

    @window = new AM.Window @

    AC.Keyboard.initialize()

    # TODO: Should this be its own class with enumeration?
    @components = new ReactiveField []

    @components.add = (component) =>
      components = @components()

      # Don't add a component twice.
      return if _.contains components, component

      @components components.concat component
      @_addComponent component

    @components.remove = (component) =>
      @components _.without @components(), component
      @_removeComponent component

    @_enabledComponents = new ReactiveField []
    @_visibleComponents = new ReactiveField []

    # Make sure components are always sorted. We don't fire recomputation after sorting since we're always traversing
    # over these arrays only from our own code that runs during tick.
    Tracker.autorun =>
      components = @_enabledComponents()

      sortedComponents = _.sortBy components, (component) =>
        component.updateOrder?() or 0

      # Replace array in-place to prevent triggering recomputation.
      components.length = 0
      components.push component for component in sortedComponents

    Tracker.autorun =>
      return

      components = @_visibleComponents()

      sortedComponents = _.sortBy components, (component) =>
        component.drawOrder?() or 0

      # Replace array in-place to prevent triggering recomputation.
      components.length = 0
      components.push component for component in sortedComponents

    # Array for storing components for initialization.
    @_componentsList = []

  onCreated: ->
    super

    @run()

  onDestroyed: ->
    super

    @endRun()

  run: ->
    # Initialize all app components.
    @initialize()

    # Start update/draw loop.
    window.requestAnimationFrame (timestamp) =>
      @tick timestamp

    # Listen for app unload.
    $(window).unload =>
      @endRun()

  tick: (currentFrameTime) ->
    @lastFrameTime or= currentFrameTime
    elapsedTime = (currentFrameTime - @lastFrameTime) / 1000
    @lastFrameTime = currentFrameTime

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

  initialize: ->
    while @_componentsList.length
      component = @_componentsList.shift()
      component.initialize?()

    @_initializeDone = true

  update: (appTime) ->
    # Copy the array in case it changes during traversal.
    @_componentsList.push component for component in @_enabledComponents()

    for component in @_componentsList
      component.update appTime

    @_componentsList.length = 0

  beginDraw: ->
    true

  draw: (appTime) ->
    # Copy the array in case it changes during traversal.
    @_componentsList.push component for component in @_visibleComponents()

    for component in @_componentsList
      component.draw appTime

    @_componentsList.length = 0

  endDraw: ->

  endRun: ->

  renderAppComponent: ->
    @currentData().renderComponent?(@currentComponent()) or null

  _addComponent: (component) ->
    # Initialize component if it's being added after main initialize has been called.
    if @_initializeDone
      component.initialize?()

    else
      @_componentsList.push component

    # Process updatable component.
    if component.update
      # Listen for changes to enabled.
      component._enabledAutorun = Tracker.autorun =>
        # Do not react to other components being added/removed.
        enabledComponents = []
        Tracker.nonreactive =>
          enabledComponents = @_enabledComponents()

        if component.enabled?() or true
          @_enabledComponents enabledComponents.concat component

        else
          # Change array in place since recomputation is not necessary.
          enabledComponents.splice _.indexOf(enabledComponents, component), 1

    # Process drawable component.
    if component.draw
      # Listen for changes to enabled.
      component._enabledAutorun = Tracker.autorun =>
        # Do not react to other components being added/removed.
        visibleComponents = []
        Tracker.nonreactive =>
          visibleComponents = @_visibleComponents()

        if component.visible?() or true
          @_visibleComponents visibleComponents.concat component

        else
          # Change array in place since recomputation is not necessary.
          visibleComponents.splice _.indexOf(visibleComponents, component), 1

  _removeComponent: (component) ->
    unless @_initializeDone
      @_componentsList.splice _.indexOf(@_componentsList, component), 1

    if component.update
      enabledComponents = @_enabledComponents()

      enabled = component.enabled?() or true
      enabledComponents.splice _.indexOf(enabledComponents, component), 1 if enabled

      component._enabledAutorun?.stop()

    if component.draw
      visibleComponents = @_visibleComponents()

      visible = component.visible?() or true
      visibleComponents.splice _.indexOf(visibleComponents, component), 1 if visible

      component._visibleAutorun?.stop()
