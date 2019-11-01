LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Stickers extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Stickers'
  @register @id()

  @fullName: -> "stickers"

  @description: ->
    "
      They are blank stickers good for writing on them.
    "

  @initialize()

  displayInLocation: -> false
