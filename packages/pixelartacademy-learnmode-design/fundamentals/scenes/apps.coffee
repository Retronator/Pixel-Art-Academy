LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Apps'

  @location: -> PAA.PixelPad.Apps

  @initialize()
  
  things: -> [
    PAA.PixelPad.Apps.Pixeltosh if LM.Design.invasionEnabled()
  ]
