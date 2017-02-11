LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Start.AcceptanceLetter extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Start.AcceptanceLetter'
  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "acceptance letter"

  @description: ->
    "
      Every time you look at your acceptance letter to Retropolis Academy of Art it makes you smile.
    "
    
  @initialize()
