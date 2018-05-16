LOI = LandsOfIllusions
SpriteCanvas = PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas

class SpriteCanvas.ColorPicker extends SpriteCanvas.Tool
  @register 'SpriteCanvas.ColorPicker'
  
  styleClasses: ->
    'color-picker-active'

  mouseDown: (event) ->
    super

    @pickColor()

  mouseMove: (event) ->
    super

    @pickColor()

  pickColor: ->
    return unless @mouseState.leftButton

    data = @spriteData()

    # Go over all pixels to find the one we want.
    for pixel in data.pixels
      if pixel.x is @mouseState.x and pixel.y is @mouseState.y
        @spriteCanvas.drawing.palette().currentRamp data.colorMap[pixel.colorIndex].ramp

        absoluteShade = pixel.relativeShade + data.colorMap[pixel.colorIndex].shade
        @spriteCanvas.drawing.palette().currentShade absoluteShade

        return
