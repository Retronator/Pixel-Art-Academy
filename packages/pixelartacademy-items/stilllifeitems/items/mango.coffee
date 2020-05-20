LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Mango extends PAA.Items.StillLifeItems.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.Mango'
  @fullName: -> "mango"
  @description: ->
    "
      It's mango, one of the most widely cultivated fruits in the tropics.
    "

  @assetsPath: -> 'pixelartacademy/items/stilllifeitems/mango'

  @initialize()

  createAvatar: ->
    new PAA.Items.StillLifeItems.Item.Avatar.Model @,
      path: "/#{@constructor.assetsPath()}.glb"
      mass: 0.1
