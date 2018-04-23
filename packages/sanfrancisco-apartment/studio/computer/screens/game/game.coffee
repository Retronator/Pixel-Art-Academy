AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Game extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Game'

  constructor: (@computer, @gameId, @gameName, @embedName) ->
    super

  appId: -> @gameId
  name: -> @gameName

  backButtonCallback: ->
    @computer.switchToScreen @computer.screens.desktop

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true
