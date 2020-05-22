LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.Cube
  class @Small extends PAA.Items.StillLifeItems.Item
    @id: -> 'PixelArtAcademy.Items.StillLifeItems.Cube.Small'
    @fullName: -> "small cube"
    @description: ->
      "
        It's a small white cube, not more than 2 inches wide.
      "

    @assetsPath: -> 'pixelartacademy/items/stilllifeitems/cube-small'

    @initialize()

    createAvatar: ->
      new PAA.Items.StillLifeItems.Item.Avatar.Box @,
        mass: 0.11 # 5 cm³ of plaster at 849 kg/m³
        size:
          x: 0.05, y: 0.05, z: 0.05
