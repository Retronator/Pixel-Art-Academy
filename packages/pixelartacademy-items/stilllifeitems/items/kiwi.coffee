LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Kiwi extends PAA.Items.StillLifeItems.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.Kiwi'
  @fullName: -> "kiwi"
  @description: ->
    "
      It's kiwifruit with its fuzzy brown skin.
    "

  @assetsPath: -> 'pixelartacademy/items/stilllifeitems/kiwi'

  @initialize()

  createAvatar: ->
    new PAA.Items.StillLifeItems.Item.Avatar.Model @,
      path: "/#{@constructor.assetsPath()}.glb"
      mass: 0.05

  class @Half extends PAA.Items.StillLifeItems.Item
    @id: -> 'PixelArtAcademy.Items.StillLifeItems.Kiwi.Half'
    @fullName: -> "half a kiwi"
    @description: ->
      "
        It's one half of a kiwifruit.
      "

    @assetsPath: -> 'pixelartacademy/items/stilllifeitems/kiwi-half'

    @initialize()

    createAvatar: ->
      new PAA.Items.StillLifeItems.Item.Avatar.Model @,
        path: "/#{@constructor.assetsPath()}.glb"
        mass: 0.025
