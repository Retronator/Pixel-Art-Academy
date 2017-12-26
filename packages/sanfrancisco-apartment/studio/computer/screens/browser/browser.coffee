AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Browser extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Browser'

  constructor: (@computer) ->
    super

  events: ->
    super.concat
      'click .close-button': @onClickCloseButton

  onClickCloseButton: (event) ->
    @computer.switchToScreen @computer.screens.desktop
