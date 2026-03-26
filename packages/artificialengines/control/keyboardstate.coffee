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
