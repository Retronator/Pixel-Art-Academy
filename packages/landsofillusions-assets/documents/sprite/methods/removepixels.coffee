AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.removePixel.method (spriteId, layerIndex, pixel, combineHistory) ->
  LOI.Assets.Sprite.removePixels spriteId, layerIndex, [pixel], combineHistory

LOI.Assets.Sprite.removePixels.method (spriteId, layerIndex, pixels, combineHistory) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixels, [
    x: Match.Integer
    y: Match.Integer
  ]
  check combineHistory, Match.OptionalOrNull Boolean

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.Asset._authorizeAssetAction sprite

  # Make sure the update is necessary.
  throw new AE.InvalidOperationException "No pixels are being removed." unless pixels.length

  layer = sprite.layers?[layerIndex]
  layerPixels = layer?.pixels

  throw new AE.ArgumentOutOfRangeException "There are no pixels on this layer." unless layerPixels?.length

  forwards = []
  backwards = []

  bounds = sprite.bounds
  updateBounds = not bounds

  for pixel in pixels
    if sprite.bounds?.fixed
      # Make sure pixel is inside bounds.
      unless sprite.bounds.left <= pixel.x <= sprite.bounds.right and sprite.bounds.top <= pixel.y <= sprite.bounds.bottom
        throw new AE.ArgumentOutOfRangeException "Pixel must be removed inside of fixed bounds."

    else if bounds
      # We only need to update bounds if the pixel we're removing is on the edge.
      updateBounds = true if pixel.x is bounds.left or pixel.x is bounds.right or pixel.y is bounds.top or pixel.y is bounds.bottom

    existingPixel = _.find layerPixels, (layerPixel) -> pixel.x is layerPixel.x and pixel.y is layerPixel.y
    throw new AE.ArgumentOutOfRangeException "The pixel to be deleted is not there." unless existingPixel

    forwards.push
      $pull:
        "layers.#{layerIndex}.pixels": pixel

    existingPixelIndex = layerPixels.indexOf existingPixel

    backwards.push
      $push:
        "layers.#{layerIndex}.pixels":
          $position: existingPixelIndex
          $each: [existingPixel]

    layerPixels.splice existingPixelIndex, 1

  lastForward = _.last forwards

  if updateBounds
    # Update bounds. They might be null (empty image) so account for that.
    pixelsCount = _.sumBy sprite.layers, (layer) => layer?.pixels?.length or 0

    # Clear bounds if we're removing the last pixels.
    if pixelsCount is pixels.length
      lastForward.$unset ?= {}
      lastForward.$unset.bounds = true

    else
      # Recalculate bounds completely.
      bounds = null

      for layer, index in sprite.layers when layer?.pixels
        originX = layer.origin?.x or 0
        originY = layer.origin?.y or 0

        for pixel in layer.pixels
          # Skip the pixel we're removing.
          continue if index is layerIndex and _.find pixels, (removedPixel) -> pixel.x is removedPixel.x and pixel.y is removedPixel.y

          absoluteX = pixel.x + originX
          absoluteY = pixel.y + originY

          if bounds
            bounds =
              left: Math.min bounds.left, absoluteX
              right: Math.max bounds.right, absoluteX
              top: Math.min bounds.top, absoluteY
              bottom: Math.max bounds.bottom, absoluteY

          else
            bounds = left: absoluteX, right: absoluteX, top: absoluteY, bottom: absoluteY

      # See if bounds are even different.
      unless sprite.boundsMatch bounds
        lastForward.$set ?= {}
        lastForward.$set.bounds = bounds

  for forward, operationIndex in forwards
    # For the first operation, connect it only if we're combining history
    if operationIndex is 0 and not combineHistory
      sprite._applyOperation forward, backwards[operationIndex]

    else
      # All the rest of the operations need to be connected since this is one stroke.
      sprite._applyOperationAndConnectHistory forward, backwards[operationIndex]

    # Re-fetch the sprite so it reflects the new history state.
    sprite = LOI.Assets.Sprite.documents.findOne spriteId
