AC = Artificial.Control

# Static class with a reactive source of the current keyboard state.
class AC.Keyboard
  @isInitialized = false

  @initialize: ->
    return if @isInitialized
    @isInitialized = true

    @_state = new AC.KeyboardState
    @_stateDependency = new Tracker.Dependency

    $(window).keydown (event) => @onKeyDown event
    $(window).keyup (event) => @onKeyUp event

  @getState: ->
    @_stateDependency.depend()
    state = new AC.KeyboardState
    $.extend state, @_state
    state

  @onKeyDown: (event) ->
    @_state[event.keyCode] = true
    @_stateDependency.changed()

  @onKeyUp: (event) ->
    delete @_state[event.keyCode]
    @_stateDependency.changed()
