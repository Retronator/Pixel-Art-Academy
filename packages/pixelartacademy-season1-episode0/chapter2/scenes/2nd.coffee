LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ
PAA = PixelArtAcademy
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class C2.SecondStreet extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.SecondStreet'

  @location: -> Soma.SecondStreet

  @initialize()

  removeExits: ->
    # Don't prevent exit after Immersion is finished.
    return if C2.Immersion.finished()
    
    "#{Vocabulary.Keys.Directions.Southeast}": Soma.SecondAndKing
    "#{Vocabulary.Keys.Directions.Southwest}": Soma.MosconeCenter
