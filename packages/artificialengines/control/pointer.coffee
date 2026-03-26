AC = Artificial.Control

# Static class with a reactive source of the current pointer state.
class AC.Pointer
  @isInitialized = false

  @initialize: ->
    return if @isInitialized
    @isInitialized = true

    @_state = new AC.PointerState
    @_stateDependency = new Tracker.Dependency

    $document = $(document)
    $window = $(window)

    $document.on 'pointerdown', (event) => @onPointerDown event
    $document.on 'pointerup', (event) => @onPointerUp event
    
    # Create a fresh state when leaving or entering the app so that any pointer-based operations can complete
    # and we don't have any lingering buttons pressed when pointer up events aren't triggered due to loss of focus.
    resetState = =>
      @_state = new AC.PointerState
      @_stateDependency.changed()
    
    $document.on 'visibilitychange', (event) => resetState()
    $window.blur (event) => resetState()
    $window.focus (event) => resetState()

  @getState: ->
    @_stateDependency.depend()
    state = new AC.PointerState
    _.extend state, @_state
    state

  @isShortcutDown: (event, shortcut) ->
    return unless shortcut and event.button

    # Allow sending in multiple shortcuts.
    if _.isArray shortcut
      return _.some (@isShortcutDown event, shortcutItem for shortcutItem in shortcut)

    # Make sure the main button is down.
    buttonDown = true if shortcut.button and (shortcut.button is event.button)
    holdButtonDown = true if shortcut.holdButton and (shortcut.holdButton is event.button)
    return unless buttonDown or holdButtonDown

    # All shortcut's requirements are met.
    true

  @onPointerDown: (event) ->
    @_state[event.button] = true
    @_stateDependency.changed()
  
  @onPointerUp: (event) ->
    delete @_state[event.button]
    @_stateDependency.changed()
