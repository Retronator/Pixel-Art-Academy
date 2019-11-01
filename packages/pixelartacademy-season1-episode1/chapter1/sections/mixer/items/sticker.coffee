LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Sticker extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Sticker'
  @register @id()

  @fullName: -> "sticker"

  @description: ->
    "
      It is a blank sticker, good for writing on it.
    "

  @initialize()

  displayInLocation: -> false
