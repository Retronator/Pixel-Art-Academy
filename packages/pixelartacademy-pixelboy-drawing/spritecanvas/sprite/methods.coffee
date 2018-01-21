LOI = LandsOfIllusions

Meteor.methods
  spriteClear: (spriteId) ->
    check spriteId, Match.DocumentId

    LOI.Assets.Sprite.documents.update spriteId,
      $set:
        pixels: []
        bounds: null

  spriteAddPixel: (spriteId, x, y, colorIndex, relativeShade) ->
    check spriteId, Match.DocumentId
    check x, Match.Integer
    check y, Match.Integer
    check colorIndex, Match.Integer
    check relativeShade, Match.Integer

    sprite = LOI.Assets.Sprite.documents.findOne spriteId

    # Make sure the location is withing the bounds.
    return unless sprite.bounds.left <= x <= sprite.bounds.right and sprite.bounds.top <= y <= sprite.bounds.bottom

    # Add color if we don't have it yet.
    Meteor.call 'spriteSetColor', spriteId, colorIndex unless sprite.colorMap[colorIndex]

    # Delete existing pixel at this location.
    LOI.Assets.Sprite.documents.update spriteId,
      $pull:
        pixels:
          x: x
          y: y

    # Add the new pixel.
    LOI.Assets.Sprite.documents.update spriteId,
      $addToSet:
        pixels:
          x: x
          y: y
          colorIndex: colorIndex
          relativeShade: relativeShade

  spriteRemovePixel: (spriteId, x, y) ->
    check spriteId, Match.DocumentId
    check x, Match.Integer
    check y, Match.Integer

    # Remove the pixel and update bounds.
    LOI.Assets.Sprite.documents.update spriteId,
      $pull:
        pixels:
          x: x
          y: y

  spriteColorFill: (spriteId, targetX, targetY, colorIndex, relativeShade) ->
    check spriteId, Match.DocumentId
    check targetX, Match.Integer
    check targetY, Match.Integer
    check colorIndex, Match.Integer
    check relativeShade, Match.Integer

    sprite = LOI.Assets.Sprite.documents.findOne spriteId

    # Make sure the location is withing the bounds.
    return unless sprite.bounds.left <= targetX <= sprite.bounds.right and sprite.bounds.top <= targetY <= sprite.bounds.bottom

    # Create a map for fast pixel retrieval. Start will all empty objects.
    pixelMap = []
    for x in [sprite.bounds.left..sprite.bounds.right]
      pixelMap[x]=[]

      for y in [sprite.bounds.top..sprite.bounds.bottom]
        pixelMap[x][y] =
          x: x
          y: y
          colorIndex: -1
          relativeShade: -1

    # Fill occupied spots with pixels.
    for pixel in sprite.pixels
      pixelMap[pixel.x] or= []
      pixelMap[pixel.x][pixel.y] = pixel

    # Find target color.
    targetPixel = pixelMap[targetX][targetY]

    targetColor =
      colorIndex: targetPixel.colorIndex
      relativeShade: targetPixel.relativeShade

    # Add the pixel to the fringe and visited list.
    fringe = [targetPixel]
    visited = []

    while fringe.length
      testPixel = fringe.pop()

      # Find 4 neighbours and add them if not already visited.
      tryAdd = (x, y) ->
        pixel = pixelMap[x]?[y]
        return unless pixel

        # Found it. Has it been added already?
        return if visited.indexOf(pixel) > -1

        # Is it the right color?
        return unless pixel.colorIndex is targetColor.colorIndex and pixel.relativeShade is targetColor.relativeShade

        # It seems legit, add it.
        fringe.push pixel

      tryAdd testPixel.x + 1, testPixel.y
      tryAdd testPixel.x - 1, testPixel.y
      tryAdd testPixel.x, testPixel.y + 1
      tryAdd testPixel.x, testPixel.y - 1

      visited.push testPixel

    # All the visited pixels are of correct color and should be filled!

    # Add color if we don't have it yet.
    Meteor.call 'spriteSetColor', spriteId, colorIndex unless sprite.colorMap[colorIndex]

    console.log visited

    for pixel in visited
      # Replace existing pixel if it exists.
      index = sprite.pixels.indexOf pixel

      console.log index, pixel

      if index > -1
        pixel.colorIndex = colorIndex
        pixel.relativeShade = relativeShade

      else
        # We don't have this pixel in the list, so add a new one.
        sprite.pixels.push
          x: pixel.x
          y: pixel.y
          colorIndex: colorIndex
          relativeShade: relativeShade

    console.log visited

    # Replace the whole pixels array.
    LOI.Assets.Sprite.documents.update spriteId,
      $set:
        pixels: sprite.pixels
