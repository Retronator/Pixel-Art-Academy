LOI = LandsOfIllusions

class LOI.Character.Avatar.Parts.SkinShape extends LOI.Character.Avatar.Parts.Shape
  createRenderer: (engineOptions, options = {}) ->
    existingMaterialData = options.materialsData

    # Add skin material.
    bodyPart = @ancestorPartOfType LOI.Character.Part.Types.Avatar.Body
    skinPart = bodyPart.properties.skin

    options.materialsData = new ComputedField =>
      materialsData = existingMaterialData?() or {}
      skin = @options.dataLocation.absoluteAddress('skin')

      materialsData.skin =
        ramp: skinPart.hue()
        shade: skinPart.shade()

      materialsData

    super engineOptions, options
