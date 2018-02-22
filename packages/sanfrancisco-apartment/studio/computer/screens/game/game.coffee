AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Game extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Game'

  constructor: (@computer, @gameId, @gameName, @embedName) ->
    super

  events: ->
    super.concat
      'click .close-button': @onClickCloseButton

  onClickCloseButton: (event) ->
    @computer.switchToScreen @computer.screens.desktop

  appId: -> @gameId

  name: -> @gameName
