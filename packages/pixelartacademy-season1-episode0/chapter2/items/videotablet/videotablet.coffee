AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
C2 = PixelArtAcademy.Season1.Episode0.Chapter2

Vocabulary = LOI.Parser.Vocabulary

class C2.Items.VideoTablet extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Items.VideoTablet'
  @url: -> 'video-tablet'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "video tablet"
  @shortName: -> "tablet"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's a tablet with a selection of videos.
    "

  @initialize()

  isVisible: -> false
