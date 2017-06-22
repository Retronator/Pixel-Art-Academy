LOI = LandsOfIllusions

class LOI.Character.Part.SkinShape extends LOI.Character.Part.Shape
  createRenderer: (engineOptions, options = {}) ->
    existingMaterialData = options.materialsData

    # Add skin material.
    options.materialsData = new ComputedField =>
      materialsData = existingMaterialData?() or {}
      skin = @options.dataLocation.absoluteAddress('skin')

      materialsData.skin =
        ramp: skin.child('hue')()
        shade: skin.child('shade')()

      materialsData

    super engineOptions, options
