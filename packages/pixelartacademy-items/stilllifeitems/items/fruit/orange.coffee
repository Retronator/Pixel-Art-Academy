LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Orange extends PAA.Items.StillLifeItems.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.Orange'
  @fullName: -> "orange"
  @description: ->
    "
      It's an orange, naming the fruit and the color at the same time.
    "

  @assetsPath: -> 'pixelartacademy/items/stilllifeitems/fruit/orange'

  @initialize()

  createAvatar: ->
    new PAA.Items.StillLifeItems.Item.Avatar.Model @,
      path: "/#{@constructor.assetsPath()}.glb"
      mass: 0.14

  class @Half extends PAA.Items.StillLifeItems.Item
    @id: -> 'PixelArtAcademy.Items.StillLifeItems.Orange.Half'
    @fullName: -> "half a orange"
    @description: ->
      "
        It's one half of an orange.
      "

    @assetsPath: -> 'pixelartacademy/items/stilllifeitems/fruit/orange-half'

    @initialize()

    createAvatar: ->
      new PAA.Items.StillLifeItems.Item.Avatar.Model @,
        path: "/#{@constructor.assetsPath()}.glb"
        mass: 0.07
