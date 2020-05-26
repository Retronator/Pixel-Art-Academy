LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Blueberry extends PAA.Items.StillLifeItems.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.Blueberry'
  @fullName: -> "blueberry"
  @description: ->
    "
      It's just what you'd expect, a berry in blue color.
    "

  @assetsPath: -> 'pixelartacademy/items/stilllifeitems/fruit/blueberry'

  @initialize()

  createAvatar: ->
    new PAA.Items.StillLifeItems.Item.Avatar.Model @,
      path: "/#{@constructor.assetsPath()}.glb"
      mass: 0.005

  class @Leaf extends PAA.Items.StillLifeItems.Item
    @id: -> 'PixelArtAcademy.Items.StillLifeItems.Blueberry.Leaf'
    @fullName: -> "blueberry leaf"
    @description: ->
      "
        It's a leaf from a blueberry shrub.
      "

    @assetsPath: -> 'pixelartacademy/items/stilllifeitems/fruit/blueberry-leaf'

    @initialize()

    createAvatar: ->
      new PAA.Items.StillLifeItems.Item.Avatar.Model @,
        path: "/#{@constructor.assetsPath()}.glb"
        mass: 0.005
        dragMultiplier: 30
