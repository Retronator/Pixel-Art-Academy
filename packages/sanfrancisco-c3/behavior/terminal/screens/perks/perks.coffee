AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Behavior.Terminal.Perks extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Perks'

  constructor: (@terminal) ->
    super

  events: ->
    super.concat
      'click .done-button': @onClickDoneButton

  onClickDoneButton: (event) ->
    @terminal.switchToScreen @terminal.screens.character
