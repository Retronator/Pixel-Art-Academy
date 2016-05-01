class PixelArtAcademy.PixelBoy.Apps.Drawing.SpriteCanvas.Cursor
  constructor: (@spriteCanvas) ->
    
    @pixelPerfectCoordinate = new ComputedField =>
      pixelCoordinate = @spriteCanvas.mouse()?.pixelCoordinate()
      return unless pixelCoordinate

      camera = @spriteCanvas.camera()
      return unless camera

      camera.roundToDisplayPixel pixelCoordinate
    ,
      EJSON.equals

  draw: ->
    context = @spriteCanvas.context()
    scale = @spriteCanvas.camera().scale()
    pixelPerfectCoordinate = @pixelPerfectCoordinate()
    return unless pixelPerfectCoordinate

    # Only draw when the integer pixel coordinate is inside the sprite.
    pixelCoordinate = @spriteCanvas.mouse()?.pixelCoordinate()
    bounds = @spriteCanvas.drawing.spriteData().bounds

    return unless bounds.left <= pixelCoordinate.x <= bounds.right and bounds.top <= pixelCoordinate.y <= bounds.bottom

    context.lineWidth = 1 / scale

    if scale > 4
      context.strokeStyle = 'rgb(50,50,50)'
      context.setLineDash [2 / scale]

    else
      context.strokeStyle = 'rgba(50,50,50,0.5)'
      context.setLineDash []

    context.strokeRect pixelPerfectCoordinate.x, pixelPerfectCoordinate.y, 1, 1
