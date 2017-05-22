LOI = LandsOfIllusions
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ
PAA = PixelArtAcademy
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class C3.MosconeCenter extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.MosconeCenter'

  @location: -> Soma.MosconeCenter

  @initialize()

  exits: ->
    "#{Vocabulary.Keys.Directions.Down}": Soma.MosconeStation
    "#{Vocabulary.Keys.Directions.Southwest}": Soma.MosconeStation
