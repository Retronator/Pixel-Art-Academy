LOI = LandsOfIllusions

class LOI.Character.Avatar.Parts.PartWithCustomColors extends LOI.Character.Part
  createRenderer: (options = {}) ->
    # We have to clone the options because the parent sends the same object to multiple parts.
    options = _.clone options

    # Save existing materials data, before we override it, since it would otherwise lead to a recursive loop.
    existingMaterialsDataField = options.materialsData

    # Add custom colors.
    options.materialsData = new ComputedField =>
      # Start with existing materials data.
      materialsData = _.extend {}, existingMaterialsDataField?()

      customColorsType = LOI.Character.Part.Types.Avatar.Outfit.CustomColor.options.type
      customColorsProperty = _.find @properties, (property) => property.options.type is customColorsType
      customColorsParts = customColorsProperty.parts()

      for customColorPart in customColorsParts
        name = customColorPart.properties.name.options.dataLocation()
        color = customColorPart.properties.color
        hue = color.hue()
        shade = color.shade()
        continue unless name and hue? and shade?

        # Replace or set the material with this name.
        materialsData[name] =
          ramp: hue
          shade: shade
          reflection: color.reflection()

      materialsData

    super options
