PAA = PixelArtAcademy

{cubicBezier} = require 'bresenham-zingl'

class PAA.PixelBoy.Apps.StudyPlan.Blueprint.Flowchart
  constructor: (@blueprint) ->
    @$canvas = $('<canvas>')
    @canvas = @$canvas[0]
    @context = @canvas.getContext '2d'

  drawToContext: (context) ->
    # Render the connections to our canvas.
    displayScale = @blueprint.display.scale()

    @canvas.width = @blueprint.bounds.width() / displayScale
    @canvas.height = @blueprint.bounds.height() / displayScale

    return unless @canvas.width and @canvas.height

    imageData = @context.getImageData 0, 0, @canvas.width, @canvas.height

    for connection in @blueprint.connections()
      @_drawConnection connection, imageData

    @context.putImageData imageData, 0, 0

    # Render the canvas scaled to the main context.
    context.setTransform 1, 0, 0, 1, 0, 0
    context.imageSmoothingEnabled = false
    context.drawImage @canvas, 0, 0, context.canvas.width, context.canvas.height

  _drawConnection: (connection, imageData) ->
    # Draw the curve.
    bezierPoints = @_createBezierPoints connection
    camera = @blueprint.camera()

    bezierParameters = _.flatten _.map bezierPoints, (point) =>
      # Convert points from canvas to display coordinates.
      point = camera.transformCanvasToDisplay point

      # Convert to integers and return coordinates as an array to feed into the cubicBezier method.
      [Math.floor(point.x), Math.floor(point.y)]

    cubicBezier bezierParameters..., (x, y) => @_paintPixel imageData, x, y

    # Draw the arrowhead.
    for segment in [0..2]
      x = bezierParameters[6] - segment

      for y in [bezierParameters[7] - segment..bezierParameters[7] + segment]
        @_paintPixel imageData, x, y

  _paintPixel: (imageData, x, y) ->
    return unless 0 <= x < imageData.width and 0 <= y < imageData.height

    pixelIndex = (x + y * imageData.width) * 4

    # Fill the pixel with line color (124, 180, 212).
    imageData.data[pixelIndex] = 124
    imageData.data[pixelIndex + 1] = 180
    imageData.data[pixelIndex + 2] = 212
    imageData.data[pixelIndex + 3] = 255

  _createBezierPoints: (connection) ->
    {start, end} = connection

    # Make the handle the shortest when a bit ahead of the start.
    deltaX = end.x - (start.x + 10)

    # Make the handle length grow faster going backwards.
    deltaX *= -2 if deltaX < 0

    # Make the handle half the horizontal distance, but instead of linear growth, enforce a minimum length.
    minimumStartingHandleLength = 40
    handleLength = Math.pow(deltaX, 2) / (deltaX + minimumStartingHandleLength) * 0.5 + minimumStartingHandleLength

    # Smooth out the handle towards zero at small distances.
    distance = Math.pow(Math.abs(start.y - end.y) + Math.abs(start.x - end.x), 2)
    handleLength *= distance / (distance + 1000)

    handleLength = Math.max 10, Math.min 300, handleLength

    # Create bezier control points.
    controlStart =
      x: start.x + handleLength
      y: start.y

    controlEnd =
      x: end.x - handleLength
      y: end.y

    [start, controlStart, controlEnd, end]
