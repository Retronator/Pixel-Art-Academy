LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Apps'

  @location: -> PAA.PixelPad.Apps

  @initialize()
  
  things: -> [
    PAA.PixelPad.Apps.Music if LOI.adventure.currentTapeSelectors().length
  ]
