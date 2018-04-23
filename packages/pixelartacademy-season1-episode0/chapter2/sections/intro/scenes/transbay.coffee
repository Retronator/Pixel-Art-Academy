LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ
PAA = PixelArtAcademy
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class C2.Intro.Transbay extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Intro.Transbay'

  @location: -> Soma.Transbay

  @initialize()

  exits: ->
    # Allow the player to get back into the train during the intro.
    "#{Vocabulary.Keys.Directions.In}": Soma.Caltrain
    "#{Vocabulary.Keys.Directions.South}": Soma.Caltrain
