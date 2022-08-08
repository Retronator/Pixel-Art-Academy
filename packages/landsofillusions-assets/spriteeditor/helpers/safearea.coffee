FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.SafeArea extends FM.Helper
  # FILE DATA
  # safeAreaEnabled: boolean whether to draw the safe area
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.SafeArea'
  @initialize()
  
  drawToContext: (context, options) ->
    return unless @interface.getActiveFileData()?.get 'safeAreaEnabled'

    camera = options.editor.camera()

    effectiveScale = camera.effectiveScale()

    # Draw grid.
    context.strokeStyle = "rgba(25,25,25,0.5)"
    context.lineWidth = 1 / effectiveScale
    context.beginPath()

    for y in [-180..180] by 40
      pixelPerfectCoordinate = camera.roundCanvasToWindowPixel x: 0, y: y
      context.moveTo -240, pixelPerfectCoordinate.y
      context.lineTo 240, pixelPerfectCoordinate.y

    for x in [-240..240] by 40
      pixelPerfectCoordinate = camera.roundCanvasToWindowPixel x: x, y: 0
      context.moveTo pixelPerfectCoordinate.x, -180
      context.lineTo pixelPerfectCoordinate.x, 180

    context.stroke()

    # Draw borders.
    context.strokeStyle = "rgba(25,25,25,1)"
    context.lineWidth = 2 / effectiveScale
    context.beginPath()

    borderCoordinate = (x, y) =>
      coordinate = camera.roundCanvasToWindowPixel {x, y}, 2
      [coordinate.x, coordinate.y]

    drawRectangle = (width, height) =>
      halfWidth = width / 2
      halfHeight = height / 2

      context.moveTo borderCoordinate(-halfWidth, -halfHeight)...
      context.lineTo borderCoordinate(halfWidth, -halfHeight)...
      context.lineTo borderCoordinate(halfWidth, halfHeight)...
      context.lineTo borderCoordinate(-halfWidth, halfHeight)...
      context.lineTo borderCoordinate(-halfWidth, -halfHeight)...

    # Draw location safe area.
    drawRectangle 320, 120

    # Draw screen safe area.
    drawRectangle 320, 240

    # Draw max area.
    drawRectangle 480, 360

    context.stroke()
