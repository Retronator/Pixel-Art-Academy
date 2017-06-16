LOI = LandsOfIllusions

class LOI.Character.Part.Shape extends LOI.Character.Part
  constructor: (options) ->
    # We add default shape properties.
    options.properties ?= []

    _.extend options.properties,
      front: new LOI.Character.Part.Property.Sprite
        name: 'front'

    super options

  createRenderer: (engineOptions) ->
    new LOI.Character.Part.Renderers.Shape engineOptions,
      skin: @options.dataLocation.absoluteAddress('skin')
      frontSpriteId: @options.dataLocation.child('front.spriteId')
