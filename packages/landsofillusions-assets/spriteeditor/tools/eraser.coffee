AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.Eraser extends LOI.Assets.SpriteEditor.Tools.Stroke
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Eraser'
  @displayName: -> "Eraser"

  @initialize()

  createPixelsFromCoordinates: (coordinates) ->
    for coordinate in coordinates
      pixel = _.clone coordinate

      # Set direct color to color of the background to fake erasing.
      pixel.directColor = r: 0.34, g: 0.34, b: 0.34

      pixel

  applyPixels: (spriteData, layerIndex, relativePixels, strokeStarted) ->
    changedPixels = for pixel in relativePixels when spriteData.getPixelForLayerAtCoordinates layerIndex, pixel.x, pixel.y
      # We must send only the coordinates to the server.
      _.pick pixel, ['x', 'y']

    return unless changedPixels.length

    LOI.Assets.Sprite.removePixels spriteData._id, layerIndex, changedPixels, not strokeStarted

    # Register that we've processed the start of the stroke.
    @startOfStrokeProcessed()
