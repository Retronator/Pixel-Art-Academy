AC = Artificial.Control

# Static class with a reactive source of the current keyboard state.
class AC.Keyboard
  @isInitialized = false

  @initialize: ->
    return if @isInitialized
    @isInitialized = true

    @_state = new AC.KeyboardState
    @_stateDependency = new Tracker.Dependency

    $(document).keydown (event) => @onKeyDown event
    $(document).keyup (event) => @onKeyUp event

  @getState: ->
    @_stateDependency.depend()
    state = new AC.KeyboardState
    _.extend state, @_state
    state

  @onKeyDown: (event) ->
    @_state[event.keyCode] = true
    @_stateDependency.changed()

  @onKeyUp: (event) ->
    # HACK: If command is pressed, no other keys will report key up events,
    # so we assume all other keys got released when command is released.
    if event.keyCode in [AC.Keys.leftMeta, AC.Keys.rightMeta]
      @_state = new AC.KeyboardState

    else
      delete @_state[event.keyCode]

    @_stateDependency.changed()
