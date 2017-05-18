LOI = LandsOfIllusions
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ
PAA = PixelArtAcademy
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class C3.SecondStreet extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.SecondStreet'

  @location: -> Soma.SecondStreet

  @initialize()

  exits: ->
    "#{Vocabulary.Keys.Directions.Southeast}": Soma.SecondAndKing
