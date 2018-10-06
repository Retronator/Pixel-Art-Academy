LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Coworking extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Coworking'

  @location: ->
    HQ.Coworking

  @initialize()

  removeThings: -> [
    HQ.ArtStudio.Reuben
  ]
