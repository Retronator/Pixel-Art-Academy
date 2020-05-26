AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.colorFill.method (spriteId, layerIndex, newTargetPixel, ignoreNormals) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check newTargetPixel, LOI.Assets.Sprite.pixelPattern
  check ignoreNormals, Boolean

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.Asset._authorizeAssetAction sprite

  # Make sure the location is within the bounds.
  layer = sprite.layers?[layerIndex]
  throw new AE.ArgumentException "Layer with provided index does not exist." unless layer
  
  absoluteX = newTargetPixel.x + (layer.origin?.x or 0)
  absoluteY = newTargetPixel.y + (layer.origin?.y or 0)

  unless sprite.bounds and sprite.bounds.left <= absoluteX <= sprite.bounds.right and sprite.bounds.top <= absoluteY <= sprite.bounds.bottom
    throw new AE.ArgumentOutOfRangeException "Pixel to be filled must be inside of bounds."

  forward = {}
  backward = {}

  # Create a map for fast pixel retrieval. Start will all empty objects.
  pixelMap = []

  layerPixels = layer.pixels

  # Fill occupied spots with pixels.
  for pixel in layerPixels
    pixelMap[pixel.x] ?= []
    pixelMap[pixel.x][pixel.y] = pixel

  # Find current target pixel.
  currentTargetPixel = pixelMap[newTargetPixel.x]?[newTargetPixel.y]
  
  if currentTargetPixel
    # We are filling an area with existing color. Add the pixel to the fringe list.
    fringe = [currentTargetPixel]
    visited = []
  
    while fringe.length
      testPixel = fringe.pop()
  
      # Find 4 neighbours and add them if not already visited.
      tryAdd = (x, y) ->
        pixel = pixelMap[x]?[y]
        return unless pixel
  
        # Found it. Has it been added already?
        return if pixel in visited
  
        # Is it the same color?
        return unless EJSON.equals(pixel.paletteColor, currentTargetPixel.paletteColor) and pixel.materialIndex is currentTargetPixel.materialIndex

        unless ignoreNormals
          # If the normal is present, make sure it matches too.
          return if pixel.normal and not EJSON.equals(pixel.normal, currentTargetPixel.normal)
  
        # It seems legit, add it.
        fringe.push pixel
  
      tryAdd testPixel.x + 1, testPixel.y
      tryAdd testPixel.x - 1, testPixel.y
      tryAdd testPixel.x, testPixel.y + 1
      tryAdd testPixel.x, testPixel.y - 1
  
      visited.push testPixel
  
    # All the visited pixels are of correct color and should be filled!
    for pixel in visited
      pixelIndex = layerPixels.indexOf pixel

      keys = ['paletteColor', 'directColor', 'materialIndex']
      keys.push 'normal' unless ignoreNormals

      for key in keys
        if newTargetPixel[key]?
          # Set new or existing property.
          forward.$set ?= {}
          forward.$set["layers.#{layerIndex}.pixels.#{pixelIndex}.#{key}"] = newTargetPixel[key]

        else if pixel[key]?
          # Unset existing property.
          forward.$unset ?= {}
          forward.$unset["layers.#{layerIndex}.pixels.#{pixelIndex}.#{key}"] = true

        if pixel[key]?
          # Reset the old property.
          backward.$set ?= {}
          backward.$set["layers.#{layerIndex}.pixels.#{pixelIndex}.#{key}"] = pixel[key]

        else if newTargetPixel[key]?
          # The property was not set previously, so we remove it.
          backward.$unset ?= {}
          backward.$unset["layers.#{layerIndex}.pixels.#{pixelIndex}.#{key}"] = true

  else
    # We are filling a transparent area.
    createPixel = (x, y) -> _.extend _.cloneDeep(newTargetPixel), {x, y}
    
    fringe = [newTargetPixel]
    created = []

    while fringe.length
      testPixel = fringe.pop()

      # Find 4 neighbours and add them if not already visited.
      tryAdd = (x, y) ->
        pixel = pixelMap[x]?[y]
        return if pixel

        # Found an empty spot. Has it been added already?
        return if _.find fringe, (pixel) -> pixel.x is x and pixel.y is y
        return if _.find created, (pixel) -> pixel.x is x and pixel.y is y
          
        # Is it out of bounds?
        absoluteX = x + (layer.origin?.x or 0)
        absoluteY = y + (layer.origin?.y or 0)

        return unless sprite.bounds.left <= absoluteX <= sprite.bounds.right and sprite.bounds.top <= absoluteY <= sprite.bounds.bottom

        # It seems legit, add it.
        fringe.push createPixel x, y

      tryAdd testPixel.x + 1, testPixel.y
      tryAdd testPixel.x - 1, testPixel.y
      tryAdd testPixel.x, testPixel.y + 1
      tryAdd testPixel.x, testPixel.y - 1

      created.push testPixel

    LOI.Assets.Sprite._limitLayerPixels layerPixels.length + created.length

    # All the created pixels should be added.
    forward.$push ?= {}
    forward.$push["layers.#{layerIndex}.pixels"] = $each: created

    # Going back, restore previous amount of pixels.
    backward.$push ?= {}
    backward.$push["layers.#{layerIndex}.pixels"] =
      $each: []
      $slice: layerPixels.length

  sprite._applyOperation forward, backward
