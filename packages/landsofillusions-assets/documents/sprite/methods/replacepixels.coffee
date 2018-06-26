AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.replacePixels.method (spriteId, layerIndex, pixels) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixels, [LOI.Assets.Sprite.pixelPattern]

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.VisualAsset._authorizeAssetAction sprite

  layerPixels = sprite.layers[layerIndex]?.pixels

  forward =
    $set:
      "layers.#{layerIndex}.pixels": pixels

  if layerPixels
    # Replace the old pixels.
    backward =
      $set:
        "layers.#{layerIndex}.pixels": layerPixels

  else if sprite.layers[layerIndex]
    # Delete the pixels property.
    backward =
      $unset:
        "layers.#{layerIndex}.pixels"

  else
    # Delete the whole layer. Since we can't pull by index, the best we can do is set it to null with unset.
    backward =
      $unset:
        "layers.#{layerIndex}"

  if sprite.bounds.fixed
    # Make sure pixels are inside bounds.
    for pixel in pixels
      unless sprite.bounds.left <= pixel.x <= sprite.bounds.right and sprite.bounds.top <= pixel.y <= sprite.bounds.bottom
        throw new AE.ArgumentOutOfRangeException "Pixels must fit inside of fixed bounds."

  else
    # Recalculate bounds completely.
    bounds = null

    sprite.layers[layerIndex] ?= {}
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
