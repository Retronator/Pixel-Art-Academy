LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps extends LOI.Adventure.Location
  @id: -> 'PixelArtAcademy.PixelPad.Apps'

  @initialize()

  things: -> [
    @constructor.HomeScreen
  ]
