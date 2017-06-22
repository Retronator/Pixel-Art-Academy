LOI = LandsOfIllusions

class LOI.Character.Part.Shape extends LOI.Character.Part
  constructor: (options) ->
    # We add default shape properties.
    options.properties ?= []

    _.extend options.properties,
      front: new LOI.Character.Part.Property.Sprite
        name: 'front'

    super options

  createRenderer: (engineOptions, options = {}) ->
    # Override to provide this part's renderer.
    renderer = @options.renderer or new LOI.Character.Part.Renderers.Shape

    options = _.extend {}, options,
      part: @
      frontSpriteId: @options.dataLocation.child('front.spriteId')

    renderer.create options, engineOptions
