LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Items.Passport extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Items.Passport'
  @register @id()

  @version: -> '0.0.1'

  @fullName: -> "passport"

  @description: ->
    "
      It's your mainland passport that confirms your identity.
    "

  @initialize()
