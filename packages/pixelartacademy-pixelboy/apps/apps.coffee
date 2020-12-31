LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps extends LOI.Adventure.Location
  @id: -> 'PixelArtAcademy.PixelBoy.Apps'

  @initialize()

  things: ->
    apps = [
      @constructor.HomeScreen
      @constructor.AdmissionWeek
    ]

    if unlockedApps = PAA.PixelBoy.Apps.AdmissionWeek.state 'unlockedApps'
      apps.push _.thingClass appId for appId in unlockedApps

    apps
