LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Pico8Cartridges extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.PixelArtFundamentals.Fundamentals.Pico8Cartridges'

  @location: -> PAA.Pico8.Cartridges

  @initialize()

  constructor: ->
    super arguments...

  things: ->
    Size = PAA.Tutorials.Drawing.PixelArtFundamentals.Size
    
    [
      PAA.Pico8.Cartridges.Jungle if Size.isAssetCompleted Size.SmallestRecognizableSize
    ]
