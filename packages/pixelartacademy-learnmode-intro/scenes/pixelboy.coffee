LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.PixelBoy extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.PixelBoy'

  @location: -> LM.Locations.Play

  @initialize()

  things: -> [
    LM.PixelBoy
  ]
