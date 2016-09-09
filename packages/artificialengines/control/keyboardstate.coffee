AC = Artificial.Control

class AC.KeyboardState
  getPressedKeys: ->
    _.keys @

  isKeyDown: (key) ->
    @[key]

  isKeyUp: (key) ->
    not @[key]

  isCommandDown: ->
    @[AC.Keys.leftCommand] or @[AC.Keys.rightCommand]
