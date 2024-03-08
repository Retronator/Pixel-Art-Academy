LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.PixeltoshPrograms extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.PixeltoshPrograms'

  @location: -> PAA.Pixeltosh.Programs

  @initialize()
  
  things: -> [
    PAA.Pixeltosh.Programs.Pinball if PAA.Learning.Task.getAdventureInstanceForId(LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies.SmoothCurves.id())?.completed()
  ]
