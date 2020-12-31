LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.NameTag extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.NameTag'
  @register @id()

  @fullName: -> "name tag"

  @description: ->
    "
      It's got _char's_ name written on it.
    "

  @initialize()
