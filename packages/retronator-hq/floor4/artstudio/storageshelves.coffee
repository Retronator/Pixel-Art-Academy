LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.StorageShelves extends PAA.Items.StillLifeItems.Container
  @id: -> 'Retronator.HQ.ArtStudio.StorageShelves'
  @fullName: -> "storage shelves"
  @shortName: -> "shelves"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @descriptiveName: -> "Storage ![shelves](look at shelves) holding items to draw."
  @description: ->
    "
      The shelves near the sink are where various items used for still life drawing are stored.
    "

  @startingItemQuantities: ->
    "#{PAA.Items.StillLifeItems.Cube.Small.id()}": 1

  @initialize()
