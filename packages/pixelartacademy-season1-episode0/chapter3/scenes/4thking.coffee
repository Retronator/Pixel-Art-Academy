LOI = LandsOfIllusions
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ
PAA = PixelArtAcademy
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class C3.FourthAndKing extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.FourthAndKing'

  @location: -> Soma.FourthAndKing

  @initialize()

  exits: ->
    "#{Vocabulary.Keys.Directions.Northeast}": Soma.SecondAndKing
    "#{Vocabulary.Keys.Directions.Southeast}": Soma.MissionRock
