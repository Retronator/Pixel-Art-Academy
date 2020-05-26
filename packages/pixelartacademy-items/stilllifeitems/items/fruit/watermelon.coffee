LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Watermelon extends PAA.Items.StillLifeItems.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.Watermelon'
  @fullName: -> "watermelon"
  @description: ->
    "
      It's a small watermelon, weighing about 10 pounds.
    "

  @assetsPath: -> 'pixelartacademy/items/stilllifeitems/fruit/watermelon'

  @initialize()

  createAvatar: ->
    new PAA.Items.StillLifeItems.Item.Avatar.Model @,
      path: "/#{@constructor.assetsPath()}.glb"
      mass: 5
