AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.removePixel.method (spriteId, layerIndex, pixel) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixel, Match.ObjectIncluding
    x: Match.Integer
    y: Match.Integer

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.VisualAsset._authorizeAssetAction sprite

  throw new AE.ArgumentOutOfRangeException "There are no pixels on this layer." unless sprite.layers?[layerIndex].pixels

  pixels = sprite.layers?[layerIndex].pixels
  x = pixel.x
  y = pixel.y
  
  existingPixel = _.find pixels, (pixel) -> pixel.x is x and pixel.y is y
  throw new AE.ArgumentOutOfRangeException "The pixel to be deleted is not there." unless existingPixel

  forward =
    $pull:
      "layers.#{layerIndex}.pixels": pixel

  existingPixelIndex = pixels.indexOf existingPixel

  backward =
    $push:
      "layers.#{layerIndex}.pixels":
        $position: existingPixelIndex
        $each: [existingPixel]

  if sprite.bounds?.fixed
    # Make sure pixel is inside bounds.
    unless sprite.bounds.left <= pixel.x <= sprite.bounds.right and sprite.bounds.top <= pixel.y <= sprite.bounds.bottom
      throw new AE.ArgumentOutOfRangeException "Pixel must be added inside of fixed bounds."

  else
    # Update bounds. They might be null (empty image) so account for that.
    bounds = sprite.bounds

    pixelsCount = _.sumBy sprite.layers, (layer) => layer.pixels?.length or 0

    # We only need to update bounds if the pixel we're removing is on the edge.
    if bounds and (x is bounds.left or x is bounds.right or y is bounds.top or y is bounds.y)
      # Clear bounds if we're removing the last pixel.
      if pixelsCount is 1
        forward.$unset ?= {}
        forward.$unset.bounds = true

      else
        # Recalculate bounds completely.
        bounds = null

        for layer, index in sprite.layers
          for pixel in layer.pixels
            # Skip the pixel we're removing
            continue if index is layerIndex and pixel.x is x and pixel.y is y

            if bounds
              bounds =
                left: Math.min bounds.left, pixel.x
                right: Math.max bounds.right, pixel.x
                top: Math.min bounds.top, pixel.y
                bottom: Math.max bounds.bottom, pixel.y

            else
              bounds = left: pixel.x, right: pixel.x, top: pixel.y, bottom: pixel.y

        forward.$set ?= {}
        forward.$set.bounds = bounds

  sprite._applyOperation forward, backward
