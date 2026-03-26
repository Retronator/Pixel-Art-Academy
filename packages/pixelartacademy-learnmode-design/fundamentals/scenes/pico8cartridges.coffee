LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Design.Fundamentals.Pico8Cartridges extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Design.Fundamentals.Pico8Cartridges'

  @location: -> PAA.Pico8.Cartridges

  @initialize()

  constructor: ->
    super arguments...

  things: -> [
    PAA.Pico8.Cartridges.Invasion if LM.Design.Fundamentals.Goals.Invasion.Start.completed()
  ]
