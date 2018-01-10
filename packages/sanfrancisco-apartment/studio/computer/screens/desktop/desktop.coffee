AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Desktop extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Desktop'

  constructor: (@computer) ->
    super

  events: ->
    super.concat
      'click .app-button': @onClickAppButton

  onClickAppButton: (event) ->
    $button = $(event.target)
    screenName = $button.data('screen')
    
    @computer.switchToScreen @computer.screens[screenName]
