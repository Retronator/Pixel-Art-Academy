AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Game extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Game'

  constructor: (@computer, @gameId, @gameName, @embedName) ->
    super

  appId: -> @gameId
  name: -> @gameName
    
  onRendered: ->
    super

    @autorun (computation) =>
      display = @callAncestorWith 'display'

      scale = display.scale() / 2

      @$('.embed').css
        transform: "scale(#{scale})"

  backButtonCallback: ->
    @computer.switchToScreen @computer.screens.desktop

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true
