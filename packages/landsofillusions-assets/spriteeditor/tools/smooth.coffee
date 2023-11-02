AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Smooth extends LOI.Assets.SpriteEditor.Tools.AliasedStroke
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Smooth'
  @displayName: -> "Smooth"

  @initialize()

  createPixelsFromCoordinates: (coordinates) ->
    for coordinate in coordinates
      pixel = _.clone coordinate
      pixel

  applyPixels: (assetData, layerIndex, relativePixels, strokeStarted) ->
    smoothAmount = 0.2
    LOI.Assets.Sprite.smoothPixels assetData._id, layerIndex, relativePixels, smoothAmount, not strokeStarted

    # Register that we've processed the start of the stroke.
    @startOfStrokeProcessed()
