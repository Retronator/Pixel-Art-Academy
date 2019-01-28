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

  applyPixels: (spriteData, layerIndex, pixels) ->
    for pixel in pixels
      # See if there even is a pixel there.
      continue unless _.find spriteData.layers?[layerIndex]?.pixels, (searchPixel) -> pixel.x is searchPixel.x and pixel.y is searchPixel.y

      # We must send only the coordinates to the server.
      pixel = _.pick pixel, ['x', 'y']

      LOI.Assets.Sprite.removePixel spriteData._id, layerIndex, pixel
