LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode
PAF = LM.PixelArtFundamentals

class PAF.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Apps'

  @location: -> PAA.PixelBoy.Apps

  @initialize()

  things: -> [
    PAA.PixelBoy.Apps.StudyPlan
  ]
