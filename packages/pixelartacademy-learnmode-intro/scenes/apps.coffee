LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Apps'

  @location: -> PAA.PixelBoy.Apps

  @initialize()

  things: ->
    apps = [
      PAA.PixelBoy.Apps.LearnMode
    ]

    if unlockedApps = PAA.PixelBoy.Apps.LearnMode.state 'unlockedApps'
      apps.push _.thingClass appId for appId in unlockedApps

    apps
