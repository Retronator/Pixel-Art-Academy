LOI = LandsOfIllusions

class LOI.Character.Avatar.Parts.SkinShape extends LOI.Character.Avatar.Parts.Shape
  constructor: (options) ->
    super

    _.merge options,
      materials:
        skin: (part) ->
          bodyPart = part.ancestorPartOfType LOI.Character.Part.Types.Avatar.Body
          bodyPart.properties.skin
