AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.updateLayer.method (spriteId, layerIndex, layerUpdate) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check layerUpdate, Match.ObjectIncluding
    name: Match.OptionalOrNull String
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
      if layerUpdate.name
        forward.$set ?= {}
        forward.$set["layers.#{layerIndex}.name"] = layerUpdate.name

        if layer.name
          backward.$set ?= {}
          backward.$set["layers.#{layerIndex}.name"] = layer.name

        else
          backward.$unset ?= {}
          backward.$unset["layers.#{layerIndex}.name"] = layerUpdate.name

      if layerUpdate.origin
        if layer.origin
          # Apply each coordinate separately.
          for coordinate in ['x', 'y', 'z']
            if layerUpdate.origin[coordinate]
              forward.$set ?= {}
              forward.$set["layers.#{layerIndex}.origin.#{coordinate}"] = layerUpdate.origin[coordinate]

              if layer.origin[coordinate]
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

  # Add the new layer to layers.
  forward.$unset ?= {}
  forward.$unset["layers.#{layerIndex}"] = true

  backward.$set ?= {}
  backward.$set["layers.#{layerIndex}"] = layer

  sprite._applyOperation forward, backward
