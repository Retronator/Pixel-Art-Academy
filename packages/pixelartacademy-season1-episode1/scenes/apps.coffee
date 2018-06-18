LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1
HQ = Retronator.HQ

class E1.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Apps'

  @location: -> PAA.PixelBoy.Apps

  @initialize()

  constructor: ->
    super

  things: ->
    apps = []
    
    obtainableApps = [
      PAA.PixelBoy.Apps.Pico8
    ]

    for appClass in obtainableApps
      hasApp = appClass.state 'inInventory'
      apps.push appClass if hasApp

    apps
