LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Systems extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Systems'

  @location: -> PAA.PixelPad.Systems

  @initialize()
  
  things: -> [
    #PAA.PixelPad.Systems.ToDo
  ]
