LOI = LandsOfIllusions

class LOI.Character.Part.Renderers.Shape extends LOI.Character.Part.Renderers.Renderer
  constructor: ->
    super

    # Prepare renderer only when it has been created with engine options passed in.
    return unless @engineOptions

    @materialsData = new ComputedField =>
      # Provide character's skin color.
      skin:
        ramp: @options.skin.child('hue')()
        shade: @options.skin.child('shade')()

    # Shape renderer subscribes to all sprite directions and draws the one needed by the engine.
    @frontSpriteData = new ComputedField =>
      return unless spriteId = @options.frontSpriteId()

      LOI.Assets.Sprite.forId.subscribe spriteId
      LOI.Assets.Sprite.documents.findOne spriteId

    @frontSprite = new LOI.Assets.Engine.Sprite
      spriteData: @frontSpriteData
      lightDirection: @engineOptions.lightDirection
      materialsData: @materialsData
      flippedHorizontal: @options.flippedHorizontal

    @activeSprite = new ComputedField =>
      @frontSprite

    @translation = new ComputedField =>
      sprite = @activeSprite()
      spriteData = sprite.options.spriteData()

      source = x: 0, y: 0
      target = x: 0, y: 0

      if origin = @options.origin
        source = (spriteData?.getLandmarkForName origin.landmark) or source

        target.x = origin.x or 0
        target.y = origin.y or 0

      x: target.x - source.x
      y: target.y - source.y

  landmarks: ->
    # Provide active sprite's landmarks, but translate them to the origin.
    return unless spriteData = @activeSprite().options.spriteData()

    translation = @translation()

    landmarks = {}

    for landmark in spriteData.landmarks
      landmarks[landmark.name] = _.extend {}, landmark,
        x: landmark.x + translation.x
        y: landmark.y + translation.y

    landmarks

  drawToContext: (context, options = {}) ->
    sprite = @activeSprite()

    context.save()

    translation = @translation()
    context.translate translation.x, translation.y

    sprite.drawToContext context, options
    context.restore()
