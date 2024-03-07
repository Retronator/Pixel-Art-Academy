LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Apps'

  @location: -> PAA.PixelPad.Apps

  @initialize()
  
  things: -> [
    PAA.PixelPad.Apps.Pixeltosh if PAA.Learning.Task.getAdventureInstanceForId(LM.PixelArtFundamentals.Fundamentals.Goals.Jaggies.SmoothCurves.id())?.completed()
  ]
