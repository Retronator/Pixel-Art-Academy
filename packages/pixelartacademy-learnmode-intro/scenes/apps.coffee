LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Apps'

  @location: -> PAA.PixelPad.Apps

  @initialize()
  
  things: -> [
    PAA.PixelPad.Apps.Drawing
    PAA.PixelPad.Apps.Pico8 if @options.parent.pico8Enabled()
  ]
