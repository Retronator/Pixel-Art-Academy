LOI = LandsOfIllusions
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ
PAA = PixelArtAcademy
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class C3.C3 extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.C3'

  @location: -> SF.Soma.C3

  @initialize()

  constructor: ->
    super

  exits: ->
    "#{Vocabulary.Keys.Directions.In}": SanFrancisco.C3.Lobby
    "#{Vocabulary.Keys.Directions.East}": SanFrancisco.C3.Lobby
