LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Bowl.Large extends PAA.Items.StillLifeItems.Item
  class @Average extends PAA.Items.StillLifeItems.Item
    @id: -> 'PixelArtAcademy.Items.StillLifeItems.Bowl.Large.Average'
    @fullName: -> "average large bowl"
    @description: ->
      "
        It's a large bowl, average in height.
      "

    @assetsPath: -> 'pixelartacademy/items/stilllifeitems/tableware/bowl-large-average'

    @initialize()

    createAvatar: ->
      new PAA.Items.StillLifeItems.Item.Avatar.Model @,
        path: "/#{@constructor.assetsPath()}.glb"
        mass: 2.5
        reflectionsRendering:
          sphereRadius: 0.143
          centerOffset:
            y: 0.143
