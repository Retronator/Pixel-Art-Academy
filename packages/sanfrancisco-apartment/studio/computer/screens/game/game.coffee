AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Game extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Game'

  constructor: (@computer, @gameName) ->
    super

  events: ->
    super.concat
      'click .close-button': @onClickCloseButton

  onClickCloseButton: (event) ->
    @computer.switchToScreen @computer.screens.desktop
