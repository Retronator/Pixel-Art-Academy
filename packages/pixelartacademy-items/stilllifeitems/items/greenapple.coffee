LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.StillLifeItems.GreenApple extends PAA.Items.StillLifeItems.Item
  @id: -> 'PixelArtAcademy.Items.StillLifeItems.GreenApple'
  @fullName: -> "green apple"
  @description: ->
    "
      It's a green apple, probably a Granny Smith.
    "

  @initialize()

  createAvatar: ->
    new PAA.Items.StillLifeItems.Item.Avatar.Model @,
      path: '/pixelartacademy/stilllifestand/items/apple-green.glb'
      mass: 0.08

  class @Half extends PAA.Items.StillLifeItems.Item
    @id: -> 'PixelArtAcademy.Items.StillLifeItems.GreenApple.Half'
    @fullName: -> "green apple half"
    @description: ->
      "
        It's one half of a green apple.
      "

    @initialize()

    createAvatar: ->
      new PAA.Items.StillLifeItems.Item.Avatar.Model @,
        path: '/pixelartacademy/stilllifestand/items/apple-green-half.glb'
        mass: 0.04
