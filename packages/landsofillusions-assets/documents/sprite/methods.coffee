RA = Retronator.Accounts
LOI = LandsOfIllusions

LOI.Assets.Sprite.insert.method ->
  RA.authorizeAdmin()

  LOI.Assets.Sprite.documents.insert {}

LOI.Assets.Sprite.update.method (spriteId, update, options) ->
  check spriteId, Match.DocumentId
  check update, Object
  check options, Match.Optional Object

  RA.authorizeAdmin()

  LOI.Assets.Sprite.documents.update spriteId, update, options

LOI.Assets.Sprite.clear.method (spriteId) ->
  check spriteId, Match.DocumentId

  RA.authorizeAdmin()

  # Delete all the pixels.
  LOI.Assets.Sprite.documents.update spriteId,
    $unset:
      layers: true
      bounds: true

LOI.Assets.Sprite.remove.method (spriteId) ->
  check spriteId, Match.DocumentId

  RA.authorizeAdmin()

  LOI.Assets.Sprite.documents.remove spriteId

LOI.Assets.Sprite.duplicate.method (spriteId) ->
  check spriteId, Match.DocumentId

  RA.authorizeAdmin()

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  # Move desired properties to a plain object.
  duplicate = {}

  for own key, value of sprite when not (key in ['name', '_id', '_schema'])
    duplicate[key] = value

  LOI.Assets.Sprite.documents.insert duplicate

LOI.Assets.Sprite.addPixel.method (spriteId, layerIndex, pixel) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixel, pixelPattern

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  authorizeSpriteAction sprite

  x = pixel.x
  y = pixel.y

  modifier = {}

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

    modifier.$set ?= {}
    modifier.$set.bounds = bounds

  if sprite.layers
    if sprite.layers[layerIndex]
      # Delete existing pixel at this location.
      LOI.Assets.Sprite.documents.update spriteId,
        $pull:
          "layers.#{layerIndex}.pixels":
            x: x
            y: y

  else
    # We have to create the layers in the first place.
    LOI.Assets.Sprite.documents.update spriteId,
      $set:
        layers: []

  # Add the new pixel and update bounds.
  modifier.$addToSet ?= {}
  modifier.$addToSet["layers.#{layerIndex}.pixels"] = pixel

  LOI.Assets.Sprite.documents.update spriteId, modifier

LOI.Assets.Sprite.removePixel.method (spriteId, layerIndex, pixel) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixel, Match.ObjectIncluding
    x: Match.Integer
    y: Match.Integer

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  authorizeSpriteAction sprite

  throw new AE.ArgumentOutOfRangeException "There are no pixels on this layer." unless sprite.layers?[layerIndex].pixels

  pixels = sprite.layers[layerIndex].pixels
  x = pixel.x
  y = pixel.y

  unless _.find(pixels, (pixel) -> pixel.x is x and pixel.y is y)
    throw new AE.ArgumentOutOfRangeException "The pixel to be deleted is not there."

  modifier =
    $pull:
      "layers.#{layerIndex}.pixels": pixel

  if sprite.bounds.fixed
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
        modifier.$unset ?= {}
        modifier.$unset.bounds = true

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

        modifier.$set ?= {}
        modifier.$set.bounds = bounds

  LOI.Assets.Sprite.documents.update spriteId, modifier

LOI.Assets.Sprite.colorFill.method (spriteId, layer, newTargetPixel) ->
  check spriteId, Match.DocumentId
  check layer, Match.Integer
  check newTargetPixel, Match.ObjectIncluding
    x: Match.Integer
    y: Match.Integer
    paletteColor: Match.Optional Match.ObjectIncluding
      ramp: Match.Integer
      shade: Match.Integer
    directColor: Match.Optional Match.ObjectIncluding
      r: Number
      g: Number
      b: Number
    materialIndex: Match.Optional Match.Integer

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  authorizeSpriteAction sprite

  # Make sure the location is within the bounds.
  unless sprite.bounds.left <= newTargetPixel.x <= sprite.bounds.right and sprite.bounds.top <= newTargetPixel.y <= sprite.bounds.bottom
    throw new AE.ArgumentOutOfRangeException "Pixel to be filled must be inside of bounds."

  # Create a map for fast pixel retrieval. Start will all empty objects.
  pixelMap = []

  layerPixels = sprite.layers[layer].pixels

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
  
        # Is it the right color?
        return unless EJSON.equals(pixel.paletteColor, currentTargetPixel.paletteColor) and pixel.materialIndex is currentTargetPixel.materialIndex
  
        # It seems legit, add it.
        fringe.push pixel
  
      tryAdd testPixel.x + 1, testPixel.y
      tryAdd testPixel.x - 1, testPixel.y
      tryAdd testPixel.x, testPixel.y + 1
      tryAdd testPixel.x, testPixel.y - 1
  
      visited.push testPixel
  
    # All the visited pixels are of correct color and should be filled!
    for pixel in visited
      for key in ['paletteColor', 'materialIndex']
        pixel[key] = newTargetPixel[key]
        delete pixel[key] unless pixel[key]?
        
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
        return if _.find created, (pixel) -> pixel.x is x and pixel.y is y
          
        # Is it out of bounds?
        return unless sprite.bounds.left <= x <= sprite.bounds.right and sprite.bounds.top <= y <= sprite.bounds.bottom

        # It seems legit, add it.
        fringe.push createPixel x, y

      tryAdd testPixel.x + 1, testPixel.y
      tryAdd testPixel.x - 1, testPixel.y
      tryAdd testPixel.x, testPixel.y + 1
      tryAdd testPixel.x, testPixel.y - 1

      created.push testPixel

    # All the created pixels should be added!
    layerPixels = layerPixels.concat created

  # Replace the whole pixels array.
  LOI.Assets.Sprite.documents.update spriteId,
    $set:
      "layers.#{layer}.pixels": layerPixels

LOI.Assets.Sprite.replacePixels.method (spriteId, layerIndex, pixels) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixels, [pixelPattern]

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  authorizeSpriteAction sprite

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

authorizeSpriteAction = (sprite) ->
  # See if user controls one of the author characters.
  authors = sprite.authors or []

  for author in authors
    try
      LOI.Authorize.characterAction author._id

      # If error was not thrown, this author is controlled by the user and action is approved.
      return

    catch
      # This author is not controlled by the user.
      continue

  # No author was authorized. Only allow editing if the user is an admin.
  RA.authorizeAdmin()

pixelPattern = Match.ObjectIncluding
  x: Match.Integer
  y: Match.Integer
  paletteColor: Match.Optional Match.ObjectIncluding
    ramp: Match.Integer
    shade: Match.Integer
  directColor: Match.Optional Match.ObjectIncluding
    r: Number
    g: Number
    b: Number
  materialIndex: Match.Optional Match.Integer
