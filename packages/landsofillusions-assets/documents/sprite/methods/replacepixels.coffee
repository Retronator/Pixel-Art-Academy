AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.replacePixels.method (spriteId, layerIndex, pixels) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixels, [LOI.Assets.Sprite.pixelPattern]

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.VisualAsset._authorizeAssetAction sprite

  modifier = {}

  if sprite.bounds.fixed
    # Make sure pixels are inside bounds.
    for pixel in pixels
      unless sprite.bounds.left <= pixel.x <= sprite.bounds.right and sprite.bounds.top <= pixel.y <= sprite.bounds.bottom
        throw new AE.ArgumentOutOfRangeException "Pixels must fit inside of fixed bounds."

  else
    # Recalculate bounds completely.
    bounds = null

    sprite.layers[layerIndex] = pixels

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

    modifier.$set ?= {}
    modifier.$set.bounds = bounds

  modifier.$set ?= {}
  modifier.$set["layers.#{layerIndex}.pixels"] = pixels

  LOI.Assets.Sprite.documents.update spriteId, modifier
