AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.smoothPixels.method (spriteId, layerIndex, pixels, amount, combineHistory) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixels, [LOI.Assets.Sprite.pixelPattern]
  check amount, Match.Range 0, 1
  check combineHistory, Match.OptionalOrNull Boolean

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.Asset._authorizeAssetAction sprite

  layer = sprite.layers?[layerIndex]
  layerPixels = layer?.pixels

  throw new AE.ArgumentOutOfRangeException "There are no pixels on this layer." unless layerPixels?.length

  forward = {}
  backward = {}

  if combineHistory
    lastHistory = sprite._getLastHistory()
    combinedForward = lastHistory.forward
    combinedBackward = lastHistory.backward

  # We need to overwrite only existing pixels, so bounds
  # couldn't have changed. Create a separate forward/backward.
  forward = $set: {}
  backward = $set: {}

  addNormal = (normal, otherNormal) ->
    normal.x += otherNormal.x
    normal.y += otherNormal.y
    normal.z += otherNormal.z

  multiplyScalar = (normal, scalar) ->
    normal.x *= scalar
    normal.y *= scalar
    normal.z *= scalar

  averageNormal = (neighbor1X, neighbor1Y, neighbor2X, neighbor2Y) ->
    return unless neighbor1 = _.find layerPixels, (pixel) -> pixel.x is neighbor1X and pixel.y is neighbor1Y
    return unless neighbor2 = _.find layerPixels, (pixel) -> pixel.x is neighbor2X and pixel.y is neighbor2Y

    normal = _.clone neighbor1.normal
    addNormal normal, neighbor2.normal
    multiplyScalar normal, 0.5

    normal

  pixelsWereChanged = false

  for pixel in pixels
    existingPixel = _.find layerPixels, (layerPixel) -> pixel.x is layerPixel.x and pixel.y is layerPixel.y
    continue unless existingPixel
    pixelsWereChanged = true

    existingPixelIndex = layerPixels.indexOf existingPixel

    horizontalNormal = averageNormal(pixel.x - 1, pixel.y, pixel.x + 1, pixel.y) or existingPixel.normal
    verticalNormal = averageNormal(pixel.x, pixel.y - 1, pixel.x, pixel.y + 1) or existingPixel.normal
    risingDiagonalNormal = averageNormal(pixel.x - 1, pixel.y - 1, pixel.x + 1, pixel.y + 1) or existingPixel.normal
    fallingDiagonalNormal = averageNormal(pixel.x - 1, pixel.y + 1, pixel.x + 1, pixel.y - 1) or existingPixel.normal

    newNormal = _.clone horizontalNormal
    addNormal newNormal, verticalNormal
    addNormal newNormal, risingDiagonalNormal
    addNormal newNormal, fallingDiagonalNormal
    multiplyScalar newNormal, 0.25 * amount

    weightedNormal = _.clone existingPixel.normal
    multiplyScalar weightedNormal, 1 - amount
    addNormal weightedNormal, newNormal

    newPixel = _.defaults
      normal: weightedNormal
    ,
      existingPixel

    # Replace existing pixel.
    forward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = newPixel
    backward.$set["layers.#{layerIndex}.pixels.#{existingPixelIndex}"] = existingPixel

  # Nothing to do if smooth was applied over area with no pixels.
  return unless pixelsWereChanged

  if combineHistory
    # Going forward, we need to override all previously set pixels.
    _.extend combinedForward.$set, forward.$set

    # Going backwards, we need to set only ones that weren't previously set.
    _.defaults combinedBackward.$set, backward.$set

    sprite._applyOperationAndCombineHistory forward, combinedForward, combinedBackward

  else
    # We're not combining history, simply do both add and overwrite operations.
    sprite._applyOperation forward, backward
