AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Assets.Sprite.replacePixels.method (spriteId, layerIndex, pixels) ->
  check spriteId, Match.DocumentId
  check layerIndex, Match.Integer
  check pixels, [LOI.Assets.Sprite.pixelPattern]

  LOI.Assets.Sprite._limitLayerPixels pixels.length

  sprite = LOI.Assets.Sprite.documents.findOne spriteId
  throw new AE.ArgumentException "Sprite does not exist." unless sprite

  LOI.Assets.Asset._authorizeAssetAction sprite

  layerPixels = sprite.layers[layerIndex]?.pixels

  forward =
    $set:
      "layers.#{layerIndex}.pixels": pixels

  if layerPixels
    # Replace the old pixels.
    backward =
      $set:
        "layers.#{layerIndex}.pixels": layerPixels

  else if sprite.layers[layerIndex]
    # Delete the pixels property.
    backward =
      $unset:
        "layers.#{layerIndex}.pixels"

  else
    # Delete the whole layer. Since we can't pull by index, the best we can do is set it to null with unset.
    backward =
      $unset:
        "layers.#{layerIndex}"

  if sprite.bounds.fixed
    # Make sure pixels are inside bounds.
    for pixel in pixels
      unless sprite.bounds.left <= pixel.x <= sprite.bounds.right and sprite.bounds.top <= pixel.y <= sprite.bounds.bottom
        throw new AE.ArgumentOutOfRangeException "Pixels must fit inside of fixed bounds."

  else
    # Recalculate bounds completely.
    if bounds = sprite.tryRecomputeBounds()
      forward.$set ?= {}
      forward.$set.bounds = bounds

  sprite._applyOperation forward, backward
