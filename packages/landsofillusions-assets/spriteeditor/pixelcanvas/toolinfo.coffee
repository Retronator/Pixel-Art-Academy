LOI = LandsOfIllusions
FM = FataMorgana

class LOI.Assets.SpriteEditor.PixelCanvas.ToolInfo
  constructor: (@pixelCanvas) ->

  drawToContext: (context) ->
    return unless text = @pixelCanvas.interface.activeTool()?.infoText?()
    
    scale = @pixelCanvas.camera().scale()
    context.imageSmoothingEnabled = false

    return unless mouseCoordinates = @pixelCanvas.mouse().canvasCoordinate()

    context.font = "#{7 / scale}px 'Adventure Pixel Art Academy'"
    context.fillStyle = "white"
    context.fillText text, mouseCoordinates.x + 16 / scale, mouseCoordinates.y + 8 / scale
