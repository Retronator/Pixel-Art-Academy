LOI = LandsOfIllusions

class LOI.Character.Avatar.Parts.Shape extends LOI.Character.Part
  constructor: (options) ->
    # We add default shape properties.
    options.properties ?= {}

    options.renderer ?= new LOI.Character.Avatar.Renderers.Shape

    _.extend options.properties,
      front: new LOI.Character.Avatar.Properties.Sprite
        name: 'front'
      frontLeft: new LOI.Character.Avatar.Properties.Sprite
        name: 'front-left'
      left: new LOI.Character.Avatar.Properties.Sprite
        name: 'left'

    super options

  createRenderer: (options = {}) ->
    # Override to provide this part's renderer.
    options = _.extend {}, options,
      part: @
      frontSpriteId: @options.dataLocation.child('front.spriteId')
      frontLeftSpriteId: @options.dataLocation.child('frontLeft.spriteId')
      leftSpriteId: @options.dataLocation.child('left.spriteId')
      frontRightSpriteId: @options.dataLocation.child('frontRight.spriteId')
      rightSpriteId: @options.dataLocation.child('right.spriteId')

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

    @options.renderer.create options
