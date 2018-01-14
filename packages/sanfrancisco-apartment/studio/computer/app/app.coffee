AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.App extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.App'

  onCreated: ->
    super

    @computer = @ancestorComponentOfType Studio.Computer
    
  events: ->
    super.concat
      'click .close-button': @onClickCloseButton

  onClickCloseButton: (event) ->
    @computer.switchToScreen @computer.screens.desktop
