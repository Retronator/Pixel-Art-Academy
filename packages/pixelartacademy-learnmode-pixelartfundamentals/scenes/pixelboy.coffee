LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode
PAF = LM.PixelArtFundamentals

class PAF.PixelBoy extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.PixelBoy'

  @location: -> LM.Locations.Play

  @initialize()

  things: -> [
    LM.PixelBoy
  ]
