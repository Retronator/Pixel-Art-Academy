AC = Artificial.Control

# A snapshot of pressed keys.
class AC.KeyboardState
  getPressedKeys: ->
    _.keys @

  isKeyDown: (key) ->
    @[key]

  isKeyUp: (key) ->
    not @[key]

  isMetaDown: ->
    @[AC.Keys.leftMeta] or @[AC.Keys.rightMeta]

  isCommandOrCtrlDown: ->
    @isMetaDown() or @isKeyDown AC.Keys.ctrl

  isShortcutDown: (shortcut) ->
    return unless shortcut

    # Make sure any required modifiers are down.
    return if shortcut.commandOrControl and not @isCommandOrCtrlDown()
    return if (shortcut.command or shortcut.win or shortcut.super) and not @isMetaDown()
    return if shortcut.shift and not @isKeyDown AC.Keys.shift
    return if shortcut.alt and not @isKeyDown AC.Keys.alt
    return if shortcut.control and not @isKeyDown AC.Keys.control

    # Make sure the main key is down.
    keyDown = true if shortcut.key and @isKeyDown shortcut.key
    holdKeyDown = true if shortcut.holdKey and @isKeyDown shortcut.holdKey
    return unless keyDown or holdKeyDown

    # All shortcut's requirements are met.
    true
