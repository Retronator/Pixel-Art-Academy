AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Smooth extends LOI.Assets.SpriteEditor.Tools.Stroke
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Smooth'
  @displayName: -> "Smooth"

  @initialize()

  createPixelsFromCoordinates: (coordinates) ->
    for coordinate in coordinates
      pixel = _.clone coordinate
      pixel

  applyPixels: (spriteData, layerIndex, relativePixels, strokeStarted) ->
    smoothAmount = 0.2
    LOI.Assets.Sprite.smoothPixels spriteData._id, layerIndex, relativePixels, smoothAmount, not strokeStarted

    # Register that we've processed the start of the stroke.
    @startOfStrokeProcessed()
