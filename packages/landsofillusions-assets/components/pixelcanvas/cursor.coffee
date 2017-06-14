LOI = LandsOfIllusions

class LOI.Assets.Components.PixelCanvas.Cursor
  constructor: (@pixelCanvas) ->
    
    @pixelPerfectCoordinate = new ComputedField =>
      pixelCoordinate = @pixelCanvas.mouse()?.pixelCoordinate()
      return unless pixelCoordinate

      camera = @pixelCanvas.camera()
      return unless camera

      camera.roundCanvasToWindowPixel pixelCoordinate
    ,
      EJSON.equals

  drawToContext: (context) ->
    scale = @pixelCanvas.camera().scale()
    effectiveScale = @pixelCanvas.camera().effectiveScale()
    pixelPerfectCoordinate = @pixelPerfectCoordinate()
    return unless pixelPerfectCoordinate
    
    context.lineWidth = 1 / effectiveScale

    if scale > 4
      context.strokeStyle = 'rgb(50,50,50)'
      context.setLineDash [2 / scale]

    else
      context.strokeStyle = 'rgba(50,50,50,0.5)'
      context.setLineDash []

    context.strokeRect pixelPerfectCoordinate.x, pixelPerfectCoordinate.y, 1, 1
