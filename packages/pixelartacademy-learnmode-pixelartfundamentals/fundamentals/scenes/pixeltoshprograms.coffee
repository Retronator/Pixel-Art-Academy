LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.PixeltoshPrograms extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.PixeltoshPrograms'

  @location: -> PAA.Pixeltosh.Programs

  @initialize()
  
  things: -> [
    PAA.Pixeltosh.Programs.Pinball if LM.PixelArtFundamentals.pinballEnabled()
  ]
