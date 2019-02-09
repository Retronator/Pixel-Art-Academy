AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.addPixel.method (spriteId, layerIndex, pixel, combineHistory) ->
  LOI.Assets.Sprite.addPixels spriteId, layerIndex, [pixel], combineHistory
  
LOI.Assets.Sprite.addPixels.method (spriteId, layerIndex, pixels, combineHistory) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixels, [LOI.Assets.Sprite.pixelPattern]
  check combineHistory, Match.OptionalOrNull Boolean

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.Asset._authorizeAssetAction sprite

  layer = sprite.layers?[layerIndex]
  layerPixels = layer?.pixels

  # Make sure the update is necessary.
  throw new AE.InvalidOperationException "No pixels are being added." unless pixels.length

  for pixel in pixels
    existingPixel = _.find layerPixels, (layerPixel) -> pixel.x is layerPixel.x and pixel.y is layerPixel.y
    throw new AE.InvalidOperationException "A pixel already contains this information." if EJSON.equals pixel, existingPixel

  forward = {}
  backward = {}

  if combineHistory
    lastHistory = sprite._getLastHistory()
    combinedForward = lastHistory.forward
    combinedBackward = lastHistory.backward

  if sprite.bounds?.fixed
    # Make sure pixels are inside bounds.
    for pixel in pixels
      unless sprite.bounds.left <= pixel.x <= sprite.bounds.right and sprite.bounds.top <= pixel.y <= sprite.bounds.bottom
        throw new AE.ArgumentOutOfRangeException "Pixels must be added inside of fixed bounds."

  else
    # Update bounds. They might be null (empty image) so account for that.
    bounds = sprite.bounds

    for pixel in pixels
      absoluteX = pixel.x + (layer?.origin?.x or 0)
      absoluteY = pixel.y + (layer?.origin?.y or 0)

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
      forward.$set ?= {}
      forward.$set.bounds = bounds

  if sprite.layers
    if layer
      if layerPixels
        overwritingPixels = []
        newPixels = []

        for pixel in pixels
          if _.find layerPixels, (layerPixel) -> pixel.x is layerPixel.x and pixel.y is layerPixel.y
            overwritingPixels.push pixel

          else
            newPixels.push pixel

        if overwritingPixels.length
          # We need to overwrite only existing pixels, so bounds
          # couldn't have changed. Create a separate forward/backward.
          overwritingForward = $set: {}
          overwritingBackward = $set: {}

          for pixel in overwritingPixels
            existingPixel = _.find layerPixels, (layerPixel) -> pixel.x is layerPixel.x and pixel.y is layerPixel.y
            existingPixelIndex = layerPixels.indexOf existingPixel

            # Replace existing pixel.
            overwritingForward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = pixel
            overwritingBackward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = existingPixel

        if newPixels.length
          LOI.Assets.Sprite._limitLayerPixels layerPixels.length + newPixels.length

          # Add the new pixels to existing layer.
          forward.$push ?= {}
          forward.$push["layers.#{layerIndex}.pixels"] = $each: newPixels

          # When going back, simply return the layer to its current length before the addition.
          backward.$push ?= {}
          backward.$push["layers.#{layerIndex}.pixels"] =
            $each: []
            $slice: layerPixels.length

        if combineHistory
          if forwardLayerPixels = combinedForward.$set?.layers?.pixels or combinedForward.$set?["layers.#{layerIndex}"]?.pixels or combinedForward.$set?["layers.#{layerIndex}.pixels"]
            # Pixels were just created. Place pixels in the initial pixels array.
            for pixel in pixels
              existingPixel = _.find forwardLayerPixels, (layerPixel) -> pixel.x is layerPixel.x and pixel.y is layerPixel.y
              existingPixelIndex = layerPixels.indexOf existingPixel

              if existingPixelIndex > -1
                # We were already setting this pixel in the previous step so we just replace it.
                forwardLayerPixels[existingPixelIndex] = pixel

              else
                # This is a new pixel even in previous history so just add it.
                forwardLayerPixels.push pixel

            sprite._applyOperationAndCombineHistory forward, combinedForward, combinedBackward

          else
            # See if last step was adding or replacing pixels.
            if combinedForward.$push?["layers.#{layerIndex}.pixels"]
              # We were adding pixels. If we're also adding pixels, merge those together.
              if newPixels.length
                combinedForward.$push?["layers.#{layerIndex}.pixels"].$each.push newPixels...
                sprite._applyOperationAndCombineHistory forward, combinedForward, combinedBackward

              if overwritingPixels.length
                # We can't combine overwriting pixels on top of adding pixels so we create a new step and connect it.
                sprite._applyOperationAndConnectHistory overwritingForward, overwritingBackward

            else
              # We were overwriting pixels. If we're also overwriting pixels, merge those together.
              if overwritingPixels.length
                # Going forward, we need to override all previously set pixels.
                _.extend combinedForward.$set, overwritingForward.$set

                # Going backwards, we need to set only ones that weren't previously set.
                _.defaults combinedBackward.$set, overwritingBackward.$set

                sprite._applyOperationAndCombineHistory overwritingForward, combinedForward, combinedBackward

              if newPixels.length
                # We can't combine adding pixels on top of overwriting pixels so we create a new step and connect it.
                sprite._applyOperationAndConnectHistory forward, backward

        else
          # We're not combining history, simply do both add and overwrite operations.
          sprite._applyOperation forward, backward if newPixels.length
          sprite._applyOperation overwritingForward, overwritingBackward if overwritingPixels.length

        # We've applied all operations.
        return

      else
        # Add the new pixel to a new layer.
        forward.$set ?= {}
        forward.$set["layers.#{layerIndex}.pixels"] = [pixel]

        backward.$set ?= {}
        backward.$set["layers.#{layerIndex}.pixels"] = []

        throw new AE.InvalidOperation "Combining history not allowed when first adding a pixel to a layer." if combineHistory

    else
      # We have to create the layer in the first place.
      forward.$set ?= {}
      forward.$set["layers.#{layerIndex}"] = pixels: [pixel]

      backward.$set ?= {}
      backward.$set["layers.#{layerIndex}"] = null

      throw new AE.InvalidOperationException "Combining history not allowed when creating a new layer." if combineHistory

  else
    # We have to create the layers in the first place.
    layers = []
    layers[layerIndex] =
      pixels: [pixel]
    
    forward.$set ?= {}
    forward.$set.layers = layers

    backward.$unset ?= {}
    backward.$unset.layers = true

    throw new AE.InvalidOperation "Combining history not allowed when creating a new layer." if combineHistory

  sprite._applyOperation forward, backward
