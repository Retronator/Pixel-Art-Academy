LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ
PAA = PixelArtAcademy
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class C2.Cafe extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Cafe'

  @location: -> HQ.Cafe

  @initialize()

  removeExits: ->
    # Don't prevent exit after Immersion is finished.
    return if C2.Immersion.finished()

    # Don't prevent exit if user played through DareToDream.
    return if PAA.Season1.Episode0.Chapter1.state('startTime')?

    "#{Vocabulary.Keys.Directions.East}": Soma.SecondStreet
    "#{Vocabulary.Keys.Directions.Out}": Soma.SecondStreet
