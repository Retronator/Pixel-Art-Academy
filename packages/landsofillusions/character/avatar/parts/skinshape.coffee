LOI = LandsOfIllusions

class LOI.Character.Avatar.Parts.SkinShape extends LOI.Character.Avatar.Parts.Shape
  @defaultSkin =
    hue: => LOI.Assets.Palette.Atari2600.hues.peach
    shade: => 4

  constructor: (options) ->
    super arguments...

    _.merge options,
      materials:
        skin: (part) =>
          bodyPart = part.ancestorPartOfType LOI.Character.Part.Types.Avatar.Body
          bodyPart?.properties.skin or @constructor.defaultSkin
