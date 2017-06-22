LOI = LandsOfIllusions

class LOI.Character.Part.CustomColors extends LOI.Character.Part
  createRenderer: (engineOptions, options = {}) ->
    existingMaterialData = options.materialsData

    # Add custom colors.
    options.materialsData = new ComputedField =>
      # We have to clone existing material data because the parent sends the same object to multiple parts.
      materialsData = _.extend {}, existingMaterialData?()

      customColorsProperty = _.find @properties, (property) => property.options.type is 'CustomColor'

      return unless customColorsFields = customColorsProperty.options.dataLocation().data()?.fields

      for customColorOrder, customColor of customColorsFields
        nameField = customColor.node.fields.name
        colorField = customColor.node.fields.color

        continue unless nameField?.value

        materialsData[nameField.value] =
          ramp: colorField.node.fields.hue.value
          shade: colorField.node.fields.shade.value

      materialsData

    super engineOptions, options
