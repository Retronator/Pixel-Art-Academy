LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Table extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Table'
  @register @id()

  @fullName: -> "table"

  @description: ->
    "
      It's the sign-in table with stickers and markers on it.
    "

  @illustration: ->
    mesh: 'retronator/hq/floor3/gallery/gallery'
    object: 'Mixer table'

  @initialize()

  displayInLocation: -> false
