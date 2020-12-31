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
      backLeft: new LOI.Character.Avatar.Properties.Sprite
        name: 'back-left'
      back: new LOI.Character.Avatar.Properties.Sprite
        name: 'back'
      backRight: new LOI.Character.Avatar.Properties.Sprite
        name: 'back-right'
      right: new LOI.Character.Avatar.Properties.Sprite
        name: 'right'
      frontRight: new LOI.Character.Avatar.Properties.Sprite
        name: 'front-right'

    super options

  createRenderer: (options = {}) ->
    # Override to provide this part's renderer.
    options = _.extend {}, options,
      part: @
      frontSpriteId: @options.dataLocation.child('front.spriteId')
      frontLeftSpriteId: @options.dataLocation.child('frontLeft.spriteId')
      leftSpriteId: @options.dataLocation.child('left.spriteId')
      backLeftSpriteId: @options.dataLocation.child('backLeft.spriteId')
      backSpriteId: @options.dataLocation.child('back.spriteId')
      backRightSpriteId: @options.dataLocation.child('backRight.spriteId')
      rightSpriteId: @options.dataLocation.child('right.spriteId')
      frontRightSpriteId: @options.dataLocation.child('frontRight.spriteId')

    existingMaterialData = options.materialsData

    # Add materials.
    for materialName, materialProvider of @options.materials
      continue unless materialProperty = materialProvider @

      do (materialName, materialProperty) ->
        options.materialsData = new ComputedField =>
          materialsData = existingMaterialData?() or {}

          materialsData[materialName] =
            ramp: materialProperty.hue()
            shade: materialProperty.shade()
            reflection: materialProperty.reflection()

          materialsData

    @options.renderer.create options

  setRot8Sprites: (path) ->
    # See which of the directions there are sprites of.
    for property, side of LOI.Engine.RenderingSides.Keys
      name = "#{path}/#{_.kebabCase side}"

      continue unless sprite = LOI.Assets.Sprite.documents.findOne {name}

      spriteIdLocation = @properties[side].options.dataLocation.child 'spriteId'
      spriteIdLocation sprite._id
