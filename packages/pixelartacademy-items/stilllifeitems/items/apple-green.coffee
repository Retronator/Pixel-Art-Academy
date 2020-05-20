LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Apple.Green extends PAA.Items.StillLifeItems.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.Apple.Green'
  @fullName: -> "green apple"
  @description: ->
    "
      It's a green apple, probably a Granny Smith.
    "

  @assetsPath: -> 'pixelartacademy/items/stilllifeitems/apple-green'

  @initialize()

  createAvatar: ->
    new PAA.Items.StillLifeItems.Item.Avatar.Model @,
      path: "/#{@constructor.assetsPath()}.glb"
      mass: 0.08

  class @Half extends PAA.Items.StillLifeItems.Item
    @id: -> 'PixelArtAcademy.Items.StillLifeItems.Apple.Green.Half'
    @fullName: -> "half a green apple"
    @description: ->
      "
        It's one half of a green apple.
      "

    @assetsPath: -> 'pixelartacademy/items/stilllifeitems/apple-green-half'

    @initialize()

    createAvatar: ->
      new PAA.Items.StillLifeItems.Item.Avatar.Model @,
        path: "/#{@constructor.assetsPath()}.glb"
        mass: 0.04
