LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Raspberry extends PAA.Items.StillLifeItems.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.Raspberry'
  @fullName: -> "raspberry"
  @description: ->
    "
      It's a juicy, delicious raspberry. Mmmmm.
    "

  @assetsPath: -> 'pixelartacademy/items/stilllifeitems/fruit/raspberry'

  @initialize()

  createAvatar: ->
    new PAA.Items.StillLifeItems.Item.Avatar.Model @,
      path: "/#{@constructor.assetsPath()}.glb"
      mass: 0.005

  class @Leaf extends PAA.Items.StillLifeItems.Item
    @id: -> 'PixelArtAcademy.Items.StillLifeItems.Raspberry.Leaf'
    @fullName: -> "raspberry leaf"
    @description: ->
      "
        It's a leaf of a raspberry bush.
      "

    @assetsPath: -> 'pixelartacademy/items/stilllifeitems/raspberry-leaf'

    @initialize()

    createAvatar: ->
      new PAA.Items.StillLifeItems.Item.Avatar.Model @,
        path: "/#{@constructor.assetsPath()}.glb"
        mass: 0.005
        dragMultiplier: 30
