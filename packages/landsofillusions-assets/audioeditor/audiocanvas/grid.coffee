LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AudioCanvas.Grid
  constructor: (@audioCanvas) ->

  drawToContext: (context) ->
    camera = @audioCanvas.camera()
    scale = camera.scale()
    displayScale = @audioCanvas.display.scale()
    viewportBounds = camera.viewportBounds

    context.strokeStyle = "#00187c"
    context.lineWidth = 1 / scale
    context.beginPath()

    gridBounds =
      left: viewportBounds.left()
      top: viewportBounds.top()
      right: viewportBounds.right()
      bottom: viewportBounds.bottom()

    spacing = 64

    for minProperty in ['left', 'top']
      gridBounds[minProperty] = Math.floor(gridBounds[minProperty] / spacing) * spacing

    for minProperty in ['right', 'bottom']
      gridBounds[minProperty] = Math.ceil(gridBounds[minProperty] / spacing) * spacing

    for y in [gridBounds.top..gridBounds.bottom] by spacing
      pixelPerfectCoordinate = camera.roundCanvasToWindowPixel
        x: 0
        y: y
      ,
        displayScale

      context.moveTo gridBounds.left, pixelPerfectCoordinate.y
      context.lineTo gridBounds.right, pixelPerfectCoordinate.y

    for x in [gridBounds.left..gridBounds.right] by spacing
      pixelPerfectCoordinate = camera.roundCanvasToWindowPixel
        x: x
        y: 0
      ,
        displayScale

      context.moveTo pixelPerfectCoordinate.x, gridBounds.top
      context.lineTo pixelPerfectCoordinate.x, gridBounds.bottom

    context.stroke()
