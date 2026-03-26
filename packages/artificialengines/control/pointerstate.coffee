AC = Artificial.Control

# A snapshot of pressed buttons.
class AC.PointerState
  getPressedButtons: ->
    _.keys @

  isButtonDown: (button) ->
    @[button]

  isButtonUp: (button) ->
    not @[button]
