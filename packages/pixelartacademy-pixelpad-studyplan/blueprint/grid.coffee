LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.StudyPlan.Blueprint.Grid
  constructor: (@blueprint) ->

  drawToContext: (context) ->
    camera = @blueprint.camera()
    scale = camera.scale()
    displayScale = @blueprint.display.scale()
    viewportBounds = camera.viewportBounds

    context.strokeStyle = "#20507c"
    context.lineWidth = 1 / scale
    context.beginPath()

    gridBounds =
      left: viewportBounds.left()
      top: viewportBounds.top()
      right: viewportBounds.right()
      bottom: viewportBounds.bottom()

    spacing = 12

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
