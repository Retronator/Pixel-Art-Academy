AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.flipHorizontal.method (spriteId, layerIndex) ->
  transformPixels spriteId, layerIndex, (pixel) =>
    pixel.x *= -1
    pixel.normal.x *= -1
  
transformPixels = (spriteId, layerIndex, transform) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.Asset._authorizeAssetAction sprite

  throw new AE.ArgumentOutOfRangeException "There are no pixels on this layer." unless sprite.layers?[layerIndex].pixels

  layerPixels = sprite.layers[layerIndex].pixels

  pixels = _.cloneDeep layerPixels 
  transform pixel for pixel in pixels

  forward =
    $set:
      "layers.#{layerIndex}.pixels": pixels

  backward =
    $set:
      "layers.#{layerIndex}.pixels": layerPixels

  if sprite.bounds.fixed
    # Make sure pixels are inside bounds.
    for pixel in pixels
      unless sprite.bounds.left <= pixel.x <= sprite.bounds.right and sprite.bounds.top <= pixel.y <= sprite.bounds.bottom
        throw new AE.ArgumentOutOfRangeException "Pixels must fit inside of fixed bounds."

  else
    # Recalculate bounds completely.
    bounds = null

    sprite.layers[layerIndex].pixels = pixels

    for layer, index in sprite.layers
      for pixel in layer.pixels
        if bounds
          bounds =
            left: Math.min bounds.left, pixel.x
            right: Math.max bounds.right, pixel.x
            top: Math.min bounds.top, pixel.y
            bottom: Math.max bounds.bottom, pixel.y

        else
          bounds = left: pixel.x, right: pixel.x, top: pixel.y, bottom: pixel.y

    forward.$set.bounds = bounds

  sprite._applyOperation forward, backward
