AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.updateLayer.method (spriteId, layerIndex, layerUpdate) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check layerUpdate, Match.ObjectIncluding
    name: Match.OptionalOrNull String
    visible: Match.OptionalOrNull Boolean
    origin: Match.OptionalOrNull
      x: Match.OptionalOrNull Number
      y: Match.OptionalOrNull Number
      z: Match.OptionalOrNull Number

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.Asset._authorizeAssetAction sprite

  forward = {}
  backward = {}

  if sprite.layers
    if layer = sprite.layers[layerIndex]
      for property in ['name', 'visible']
        if layerUpdate[property]?
          if layerUpdate[property]? and (not _.isString(layerUpdate[property]) or layerUpdate[property].length)
            forward.$set ?= {}
            forward.$set["layers.#{layerIndex}.#{property}"] = layerUpdate[property]

          else
            forward.$unset ?= {}
            forward.$unset["layers.#{layerIndex}.#{property}"] = true

          if layer[property]?
            backward.$set ?= {}
            backward.$set["layers.#{layerIndex}.#{property}"] = layer[property]

          else
            backward.$unset ?= {}
            backward.$unset["layers.#{layerIndex}.#{property}"] = layerUpdate[property]

      if layerUpdate.origin
        if layer.origin
          # Apply each coordinate separately.
          for coordinate in ['x', 'y', 'z']
            if layerUpdate.origin[coordinate]?
              forward.$set ?= {}
              forward.$set["layers.#{layerIndex}.origin.#{coordinate}"] = layerUpdate.origin[coordinate]

              if layer.origin[coordinate]?
                backward.$set ?= {}
                backward.$set["layers.#{layerIndex}.origin.#{coordinate}"] = layer.origin[coordinate]

              else
                backward.$unset ?= {}
                backward.$unset["layers.#{layerIndex}.origin.#{coordinate}"] = true

        else
          # Simply add the origin.
          forward.$set ?= {}
          forward.$set["layers.#{layerIndex}.origin"] = layerUpdate.origin

          backward.$unset ?= {}
          backward.$unset["layers.#{layerIndex}.origin"] = true

        if layerUpdate.origin.x? or layerUpdate.origin.y?
          # Recalculate bounds completely.
          bounds = null

          for layer, index in sprite.layers when layer?.pixels
            if index is layerIndex
              # Use the new origin.
              origin =
                x: layerUpdate.origin.x ? layer.origin.x
                y: layerUpdate.origin.y ? layer.origin.y

            else
              # Use the existing origin.
              origin = layer.origin

            for pixel in layer.pixels
              absoluteX = pixel.x + (origin?.x or 0)
              absoluteY = pixel.y + (origin?.y or 0)

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

    else
      # Add the new layer to layers.
      forward.$set ?= {}
      forward.$set["layers.#{layerIndex}"] = layerUpdate

      backward.$unset ?= {}
      backward.$unset["layers.#{layerIndex}"] = true

  else
    # We have to create the layers in the first place.
    layers = []
    layers[layerIndex] = layerUpdate
    
    forward.$set ?= {}
    forward.$set.layers = layers

    backward.$unset ?= {}
    backward.$unset.layers = true

  sprite._applyOperation forward, backward

LOI.Assets.Sprite.removeLayer.method (spriteId, layerIndex) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.Asset._authorizeAssetAction sprite

  layer = sprite.layers?[layerIndex]
  throw new AE.ArgumentException "Layer does not exist." unless layer

  forward = {}
  backward = {}

  # Remove the layer from layers.
  forward.$unset ?= {}
  forward.$unset["layers.#{layerIndex}"] = true

  backward.$set ?= {}
  backward.$set["layers.#{layerIndex}"] = layer

  # Update the bounds.
  bounds = null

  for layer, index in sprite.layers when layer?.pixels and index isnt layerIndex
    for pixel in layer.pixels
      absoluteX = pixel.x + (layer.origin?.x or 0)
      absoluteY = pixel.y + (layer.origin?.y or 0)

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
    
  sprite._applyOperation forward, backward
