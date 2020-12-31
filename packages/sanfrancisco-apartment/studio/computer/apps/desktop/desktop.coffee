AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Desktop extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Desktop'

  constructor: (@computer) ->
    super arguments...
    
  apps: ->
    [
      @computer.screens.browser
      @computer.screens.email
      @computer.screens.princeOfPersia
      @computer.screens.lotusTheUltimateChallenge
    ]

  iconPath: ->
    app = @currentData()

    "/sanfrancisco/apartment/studio/computer/icons/#{app.appId()}.png"

  events: ->
    super(arguments...).concat
      'click .app-button': @onClickAppButton

  onClickAppButton: (event) ->
    app = @currentData()

    @computer.switchToScreen app
