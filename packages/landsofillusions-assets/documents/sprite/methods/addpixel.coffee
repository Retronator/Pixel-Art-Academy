AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.addPixel.method (spriteId, layerIndex, pixel, combineHistory = false) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixel, LOI.Assets.Sprite.pixelPattern
  check combineHistory, Boolean

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.Asset._authorizeAssetAction sprite

  layer = sprite.layers?[layerIndex]
  pixels = layer?.pixels
  x = pixel.x
  y = pixel.y

  # See if this pixel even needs changing.
  existingPixel = _.find pixels, (pixel) -> pixel.x is x and pixel.y is y
  throw new AE.InvalidOperationException "The pixel already contains this information." if EJSON.equals pixel, existingPixel

  forward = {}
  backward = {}

  if combineHistory
    lastHistory = sprite._getLastHistory()
    combinedForward = lastHistory.forward
    combinedBackward = lastHistory.backward

  if sprite.bounds?.fixed
    # Make sure pixel is inside bounds.
    unless sprite.bounds.left <= pixel.x <= sprite.bounds.right and sprite.bounds.top <= pixel.y <= sprite.bounds.bottom
      throw new AE.ArgumentOutOfRangeException "Pixel must be added inside of fixed bounds."

  else
    # Update bounds. They might be null (empty image) so account for that.
    bounds = sprite.bounds
    
    absoluteX = x + (layer?.origin?.x or 0)
    absoluteY = y + (layer?.origin?.y or 0)

    if bounds
      bounds =
        left: Math.min bounds.left, absoluteX
        right: Math.max bounds.right, absoluteX
        top: Math.min bounds.top, absoluteY
        bottom: Math.max bounds.bottom, absoluteY

    else
      bounds = left: absoluteX, right: absoluteX, top: absoluteY, bottom: absoluteY

    # See if bounds are even different.
    unless EJSON.equals sprite.bounds, bounds
      forward.$set ?= {}
      forward.$set.bounds = bounds

  if sprite.layers
    if pixels
      if existingPixel
        existingPixelIndex = pixels.indexOf existingPixel

        # Replace existing pixel.
        forward.$set ?= {}
        forward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = pixel

        backward.$set ?= {}
        backward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = existingPixel

        if combineHistory
          if combinedForward.$set?.layers
            # Layers were just created. Add pixel to the initial layer.
            combinedForward.$set.layers[layerIndex].pixels.push pixel

          else if combinedForward.$set?["layers.#{layerIndex}.pixels"]
            # Pixels on the layer were just created. Add pixel to the initial pixels array.
            combinedForward.$set["layers.#{layerIndex}.pixels"].push pixel

          else
            # Make sure we haven't been adding any new pixels.
            if combinedForward.$push?["layers.#{layerIndex}.pixels"]
              combinedForward = null

            else
              if combinedForward.$set?["layers.#{layerIndex}.pixels.#{existingPixelIndex}"]
                # Same pixel was already set. Replace pixel in this same operation.
                combinedForward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = pixel

              else
                # This pixel was not modified yet in combined history. Do a full replace.
                combinedForward.$set ?= {}
                combinedForward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = pixel

                combinedBackward.$set ?= {}
                combinedBackward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = existingPixel

      else
        LOI.Assets.Sprite._limitLayerPixels pixels.length + 1
        
        # Add the new pixel to existing layer.
        forward.$push ?= {}
        forward.$push["layers.#{layerIndex}.pixels"] = pixel

        backward.$pop ?= {}
        backward.$pop["layers.#{layerIndex}.pixels"] = 1

        if combineHistory
          if combinedForward.$set?.layers
            # Layers were just created. Add pixel to the initial layer.
            combinedForward.$set.layers[layerIndex].pixels.push pixel

          else if combinedForward.$set?["layers.#{layerIndex}.pixels"]
            # Pixels on the layer were just created. Add pixel to the initial pixels array.
            combinedForward.$set["layers.#{layerIndex}.pixels"].push pixel

          else
            # Make sure we haven't been replacing any pixels yet.
            setFields = _.keys combinedForward.$set

            layerPixelsRegex = new RegExp "layers\.#{layerIndex}\.pixels\."

            if _.find setFields, (setField) => setField.match layerPixelsRegex
              combinedForward = null

            else
              if combinedForward.$push?["layers.#{layerIndex}.pixels"]
                # New pixels were already added.
                if combinedForward.$push?["layers.#{layerIndex}.pixels"].$each
                  # Multiple pixels were already added. Just append the new pixel.
                  combinedForward.$push?["layers.#{layerIndex}.pixels"].$each.push pixel

                else
                  # Only a single pixel was added so far. Convert to each and add new pixel.
                  previousPixel = combinedForward.$push?["layers.#{layerIndex}.pixels"]
                  combinedForward.$push?["layers.#{layerIndex}.pixels"] = $each: [previousPixel, pixel]

                  # We can't use pop anymore to remove a single element, so we change it to slice.
                  delete combinedBackward.$pop
                  combinedBackward.$push ?= {}
                  combinedBackward.$push["layers.#{layerIndex}.pixels"] =
                    $each: []
                    $slice: pixels.length - 1

              else
                # No pixels were added yet. Create the first push.
                combinedForward.$push ?= {}
                combinedForward.$push["layers.#{layerIndex}.pixels"] = pixel

                combinedBackward.$pop ?= {}
                combinedBackward.$pop["layers.#{layerIndex}.pixels"] = 1

    else
      # Add the new pixel to a new layer.
      forward.$set ?= {}
      forward.$set["layers.#{layerIndex}.pixels"] = [pixel]

      backward.$set ?= {}
      backward.$set["layers.#{layerIndex}.pixels"] = []

      throw new AE.InvalidOperation "Combining history not allowed when first adding a pixel to a layer." if combineHistory

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

  if combineHistory
    if combinedForward
      sprite._applyOperationAndCombineHistory forward, combinedForward, combinedBackward
      
    else
      sprite._applyOperationAndConnectHistory forward, backward
    
  else
    sprite._applyOperation forward, backward
