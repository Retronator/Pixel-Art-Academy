AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Desktop extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Desktop'

  constructor: (@computer) ->
    super

  events: ->
    super.concat
      'click .browser-button': @onClickBrowserButton

  onClickBrowserButton: (event) ->
    @computer.switchToScreen @computer.screens.browser
