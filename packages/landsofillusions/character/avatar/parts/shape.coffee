LOI = LandsOfIllusions

class LOI.Character.Avatar.Parts.Shape extends LOI.Character.Part
  constructor: (options) ->
    # We add default shape properties.
    options.properties ?= {}

    options.renderer ?= new LOI.Character.Avatar.Renderers.Shape

    _.extend options.properties,
      front: new LOI.Character.Avatar.Properties.Sprite
        name: 'front'

    super options

  createRenderer: (engineOptions, options = {}) ->
    # Override to provide this part's renderer.
    options = _.extend {}, options,
      part: @
      frontSpriteId: @options.dataLocation.child('front.spriteId')

    existingMaterialData = options.materialsData

    # Add materials.
    for materialName, materialProvider of @options.materials
      materialProperty = materialProvider @

      do (materialName, materialProperty) ->
        options.materialsData = new ComputedField =>
          materialsData = existingMaterialData?() or {}

          materialsData[materialName] =
            ramp: materialProperty.hue()
            shade: materialProperty.shade()

          materialsData

    @options.renderer.create options, engineOptions
