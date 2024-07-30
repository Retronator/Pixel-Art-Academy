LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Apps'

  @location: -> PAA.PixelPad.Apps

  @initialize()
  
  things: -> [
    # Music is not available in the demo.
    # PAA.PixelPad.Apps.Music if LM.PixelArtFundamentals.Start.finished()
  ]
