AC = Artificial.Control

# A snapshot of pressed keys.
class AC.KeyboardState
  getPressedKeys: ->
    _.keys @

  isKeyDown: (key) ->
    @[key]

  isKeyUp: (key) ->
    not @[key]

  isCommandDown: ->
    @[AC.Keys.leftCommand] or @[AC.Keys.rightCommand]

  isCommandOrCtrlDown: ->
    @isCommandDown() or @isKeyDown AC.Keys.ctrl
