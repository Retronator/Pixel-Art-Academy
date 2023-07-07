LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.PixelPad extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.PixelPad'

  @location: -> LM.Locations.Play

  @initialize()

  things: -> [
    LM.PixelPad
  ]
