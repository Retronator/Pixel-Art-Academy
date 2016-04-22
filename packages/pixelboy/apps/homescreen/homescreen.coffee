PAA = PixelArtAcademy
AM = Artificial.Mirage

class PAA.PixelBoy.Apps.HomeScreen extends PAA.PixelBoy.OS.App
  @register 'PixelArtAcademy.PixelBoy.Apps.HomeScreen'

  displayName: ->
    "Home Screen"

  urlName: ->
    'homescreen'

  onRendered: ->
    super

  appUrlName: ->
    app = @currentData()
    app.urlName()

  appDisplayName: ->
    app = @currentData()
    app.displayName()
