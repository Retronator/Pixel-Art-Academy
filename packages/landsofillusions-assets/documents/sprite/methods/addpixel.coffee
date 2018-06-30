AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.addPixel.method (spriteId, layerIndex, pixel) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixel, LOI.Assets.Sprite.pixelPattern

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.VisualAsset._authorizeAssetAction sprite

  pixels = sprite.layers[layerIndex].pixels
  x = pixel.x
  y = pixel.y

  # See if this pixel even needs changing.
  existingPixel = _.find pixels, (pixel) -> pixel.x is x and pixel.y is y
  throw new AE.InvalidOperationException "The pixel already contains this information." if EJSON.equals pixel, existingPixel

  forward = {}
  backward = {}

  if sprite.bounds.fixed
    # Make sure pixel is inside bounds.
    unless sprite.bounds.left <= pixel.x <= sprite.bounds.right and sprite.bounds.top <= pixel.y <= sprite.bounds.bottom
      throw new AE.ArgumentOutOfRangeException "Pixel must be added inside of fixed bounds."

  else
    # Update bounds. They might be null (empty image) so account for that.
    bounds = sprite.bounds

    if bounds
      bounds =
        left: Math.min bounds.left, x
        right: Math.max bounds.right, x
        top: Math.min bounds.top, y
        bottom: Math.max bounds.bottom, y

    else
      bounds = left: x, right: x, top: y, bottom: y

    forward.$set ?= {}
    forward.$set.bounds = bounds

  if sprite.layers
    if sprite.layers[layerIndex]
      if existingPixel
        existingPixelIndex = pixels.indexOf existingPixel

        # Replace existing pixel.
        forward.$set ?= {}
        forward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = pixel

        backward.$set ?= {}
        backward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = existingPixel

      else
        # Allow up to 2,000 pixels per layer.
        throw new AE.ArgumentOutOfRangeException "Up to 2,000 pixels per layer are allowed." unless pixels.length < 2000
        
        # Add the new pixel to existing layer.
        forward.$push ?= {}
        forward.$push["layers.#{layerIndex}.pixels"] = pixel

        backward.$pop ?= {}
        backward.$pop["layers.#{layerIndex}.pixels"] = 1

    else
      # Add the new pixel to a new layer.
      forward.$set ?= {}
      forward.$set["layers.#{layerIndex}.pixels"] = [pixel]

      backward.$set ?= {}
      backward.$set["layers.#{layerIndex}.pixels"] = []

  else
    # We have to create the layers in the first place.
    layers = []
    layers[layerIndex] =
      pixels: [pixel]
    
    forward.$set ?= {}
    forward.$set.layers = layers

    backward.$unset ?= {}
    backward.$unset.layers = true

  sprite._applyOperation forward, backward
