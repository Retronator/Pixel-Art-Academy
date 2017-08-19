LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.MappedShape extends LOI.Character.Avatar.Renderers.Renderer
  constructor: ->
    super

    # Prepare renderer only when it has been created with engine options passed in.
    return unless @engineOptions

    # Shape renderer subscribes to all sprite directions and draws the one needed by the engine.
    @frontSpriteData = new ComputedField =>
      return unless spriteId = @options.frontSpriteId()

      LOI.Assets.Sprite.forId.subscribe spriteId
      LOI.Assets.Sprite.documents.findOne spriteId

    @frontSprite = new LOI.Assets.Engine.Sprite
      spriteData: @frontSpriteData
      lightDirection: @engineOptions.lightDirection
      materialsData: @options.materialsData
      flippedHorizontal: @options.flippedHorizontal

    @activeSprite = new ComputedField =>
      @frontSprite

    @translation = new ComputedField =>
      # Landmarks source provides landmarks we try to map to (our targets).
      targetLandmarks = @options.landmarksSource?.landmarks()

      # Source landmark is the data set directly in the sprite.
      # We try to map from sprite (source) to provided landmarks (target).
      source = x: 0, y: 0
      target = x: 0, y: 0

      # Translation in a mapped sprite is calculated to so that sprite's landmarks map onto the provided ones.
      sprite = @activeSprite()
      spriteData = sprite.options.spriteData()

      if spriteData?.landmarks and targetLandmarks
        for spriteLandmark in spriteData.landmarks
          # See if we have this landmark in our source.
          if targetLandmark = targetLandmarks[spriteLandmark.name]
            target = targetLandmark
            source.x = spriteLandmark.x or 0
            source.y = spriteLandmark.y or 0

            # For now we just attach to the first matched landmark.
            # TODO: Match to multiple landmarks and calculate necessary scaling to achieve perfect map.
            break

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
