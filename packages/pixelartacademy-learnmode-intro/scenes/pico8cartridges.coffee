LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Pico8Cartridges extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Pico8Cartridges'

  @location: -> PAA.Pico8.Cartridges

  @initialize()

  constructor: ->
    super arguments...

  things: -> [
    PAA.Pico8.Cartridges.Snake if LM.Intro.pico8Enabled()
  ]
