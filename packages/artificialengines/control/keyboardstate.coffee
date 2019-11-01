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

  isCommandOrControlDown: ->
    @isMetaDown() or @isKeyDown AC.Keys.ctrl

  isShortcutDown: (shortcut) ->
    return unless shortcut

    # Allow sending in multiple shortcuts.
    if _.isArray shortcut
      return _.some (@isShortcutDown shortcutItem for shortcutItem in shortcut)

    # Make sure any required modifiers are down.
    return if shortcut.commandOrControl and not @isCommandOrControlDown()
    return if (shortcut.command or shortcut.win or shortcut.super) and not @isMetaDown()
    return if shortcut.shift and not @isKeyDown AC.Keys.shift
    return if shortcut.alt and not @isKeyDown AC.Keys.alt
    return if shortcut.control and not @isKeyDown AC.Keys.control

    # Make sure none of the other modifiers are down.
    return if @isCommandOrControlDown() and not (shortcut.command or shortcut.control or shortcut.commandOrControl)
    return if @isMetaDown() and not (shortcut.command or shortcut.win or shortcut.super or shortcut.commandOrControl)

    for keyName in ['shift', 'alt', 'control']
      key = AC.Keys[keyName]
      return if @isKeyDown(key) and not (shortcut[keyName] or (shortcut.key is key) or (shortcut.holdKey is key))

    # Make sure the main key is down.
    keyDown = true if shortcut.key and @isKeyDown shortcut.key
    holdKeyDown = true if shortcut.holdKey and @isKeyDown shortcut.holdKey
    return unless keyDown or holdKeyDown

    # All shortcut's requirements are met.
    true
