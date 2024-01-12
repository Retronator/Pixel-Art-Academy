LOI = LandsOfIllusions
FM = FataMorgana

class LOI.Assets.SpriteEditor.PixelCanvas.ToolInfo
  constructor: (@pixelCanvas) ->
    @invertColorData = new ComputedField =>
      @pixelCanvas.interface.getActiveFileData()?.child 'invertUIColors'

    @invertColor = new ComputedField =>
      @invertColorData()?.value()

  drawToContext: (context) ->
    return unless text = @pixelCanvas.interface.activeTool()?.infoText?()
    
    scale = @pixelCanvas.camera().scale()
    context.imageSmoothingEnabled = false

    return unless pointerCoordinates = @pixelCanvas.pointer().canvasCoordinate()

    if @invertColor()
      context.fillStyle = "rgb(230,230,230)"

    else
      context.fillStyle = "rgb(25,25,25)"

    context.font = "#{7 / scale}px 'Adventure Retronator'"
    context.fillText text, pointerCoordinates.x + 16 / scale, pointerCoordinates.y + 8 / scale
