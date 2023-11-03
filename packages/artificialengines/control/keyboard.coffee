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

  @isCommandOrControlDown: (event) ->
    event.metaKey or event.ctrlKey

  @isShortcutDown: (event, shortcut) ->
    return unless shortcut

    # Allow sending in multiple shortcuts.
    if _.isArray shortcut
      return _.some (@isShortcutDown event, shortcutItem for shortcutItem in shortcut)

    # Make sure any required modifiers are down.
    return if shortcut.commandOrControl and not @isCommandOrControlDown event
    return if (shortcut.command or shortcut.win or shortcut.super) and not event.metaKey
    return if shortcut.shift and not event.shiftKey
    return if shortcut.alt and not event.altKey
    return if shortcut.control and not event.ctrlKey

    # Make sure none of the other modifiers are down.
    return if @isCommandOrControlDown(event) and not (shortcut.command or shortcut.control or shortcut.commandOrControl)
    return if event.metaKey and not (shortcut.command or shortcut.win or shortcut.super or shortcut.commandOrControl)
    return if event.shiftKey and not (shortcut.shift or (shortcut.key is AC.Keys.shift) or (shortcut.holdKey is AC.Keys.shift))
    return if event.altKey and not (shortcut.alt or (shortcut.key is AC.Keys.alt) or (shortcut.holdKey is AC.Keys.alt))
    return if event.ctrlKey and not (shortcut.control or (shortcut.key is AC.Keys.ctrl) or (shortcut.holdKey is AC.Keys.ctrl) or shortcut.commandOrControl)
    
    # Make sure the main key is down.
    keyDown = true if shortcut.key and (shortcut.key is event.keyCode)
    holdKeyDown = true if shortcut.holdKey and (shortcut.holdKey is event.keyCode)
    return unless keyDown or holdKeyDown

    # All shortcut's requirements are met.
    true

  @onKeyDown: (event) ->
    # HACK: If command is pressed, no other non-modifier keys will report key up events,
    # so we assume all other keys got released prior to this new key being pressed.
    @_createNewStateWithRetainedModifierKeys() if @_state.isMetaDown()

    @_state[event.keyCode] = true
    @_stateDependency.changed()

  @onKeyUp: (event) ->
    # HACK: If command is pressed, no other non-modifier keys will report key up events,
    # so we assume all other keys got released when command is released.
    @_createNewStateWithRetainedModifierKeys() if event.keyCode in [AC.Keys.leftMeta, AC.Keys.rightMeta]

    delete @_state[event.keyCode]
    @_stateDependency.changed()
    
  @_createNewStateWithRetainedModifierKeys: ->
    # Create a new state and copy only modifier keys from the previous one.
    state = new AC.KeyboardState
    
    state[modifierKey] = true for modifierKey in [AC.Keys.leftMeta, AC.Keys.rightMeta, AC.Keys.shift, AC.Keys.alt] when @_state[modifierKey]
    
    @_state = state
