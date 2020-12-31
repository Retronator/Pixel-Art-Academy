LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.ArtStudio extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.ArtStudio'

  @location: ->
    HQ.ArtStudio

  @initialize()

  removeThings: -> [
    HQ.ArtStudio.Alexandra
  ]
