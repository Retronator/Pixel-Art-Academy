AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.resize.method (spriteId, width, height) ->
  check spriteId, Match.DocumentId
  check width, Match.PositiveInteger
  check height, Match.PositiveInteger

  sprite = LOI.Assets.Sprite.documents.findOne spriteId

  # On the client we can simply quit if we don't have the sprite available.
  return if @isSimulation and not sprite

  throw new AE.ArgumentException "Sprite does not exist." unless sprite
  throw new AE.ArgumentException "Sprite needs to have bounds." unless sprite.bounds

  LOI.Assets.Asset._authorizeAssetAction sprite

  sprite.requirePixelMaps()

  # We spread the samples evenly between pixel centers, so the width of the spread is 1 pixel less than the width.
  horizontalScale = sprite.bounds.width / width
  verticalScale = sprite.bounds.height / height

  forward = $set: {}
  backward = $set: {}

  for layer, layerIndex in sprite.layers when layer.pixels
    oldPixels = layer.pixels
    newPixels = []

    for x in [0...width]
      for y in [0...height]
        # Find the coordinates to sample.
        sampleX = Math.round sprite.bounds.left - 0.5 + (x + 0.5) * horizontalScale
        sampleY = Math.round sprite.bounds.top - 0.5 + (y + 0.5) * verticalScale

        if pixel = sprite.getPixelForLayerAtAbsoluteCoordinates layerIndex, sampleX, sampleY
          newPixels.push _.defaults
            x: sprite.bounds.left + x
            y: sprite.bounds.top + y
          ,
            pixel

    forward.$set["layers.#{layerIndex}.pixels"] = newPixels
    backward.$set["layers.#{layerIndex}.pixels"] = oldPixels

    # Replace pixels in the sprite so we can do bound computations.
    layer.pixels = newPixels

  if sprite.bounds.fixed
    # Update fixed bounds to exact width and height.
    forward.$set.bounds =
      left: sprite.bounds.left
      top: sprite.bounds.top
      right: sprite.bounds.left + width - 1
      bottom: sprite.bounds.left + height - 1
      fixed: true

  else
    # Recalculate bounds completely in case due to sampling the final image isn't exactly width by height.
    if bounds = sprite.getRecomputedBoundsIfNew()
      forward.$set.bounds = bounds

  sprite._applyOperation forward, backward
