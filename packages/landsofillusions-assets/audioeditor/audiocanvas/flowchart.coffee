LOI = LandsOfIllusions

{cubicBezier} = require 'bresenham-zingl'

class LOI.Assets.AudioEditor.AudioCanvas.Flowchart
  constructor: (@audioCanvas) ->
    @$canvas = $('<canvas>')
    @canvas = @$canvas[0]
    @context = @canvas.getContext '2d'

  drawToContext: (context) ->
    # Render the connections to our canvas.
    displayScale = @audioCanvas.display.scale()

    @canvas.width = @audioCanvas.bounds.width() / displayScale
    @canvas.height = @audioCanvas.bounds.height() / displayScale

    return unless @canvas.width and @canvas.height

    imageData = @context.getImageData 0, 0, @canvas.width, @canvas.height

    for connection in @audioCanvas.connections()
      @_drawConnection connection, imageData

    @context.putImageData imageData, 0, 0

    # Render the canvas scaled to the main context.
    context.setTransform 1, 0, 0, 1, 0, 0
    context.imageSmoothingEnabled = false
    context.drawImage @canvas, 0, 0, context.canvas.width, context.canvas.height

  _drawConnection: (connection, imageData) ->
    # Draw the curve.
    bezierPoints = @_createBezierPoints connection
    camera = @audioCanvas.camera()

    bezierParameters = _.flatten _.map bezierPoints, (point) =>
      # Convert points from canvas to display coordinates.
      point = camera.transformCanvasToDisplay point

      # Convert to integers and return coordinates as an array to feed into the cubicBezier method.
      [Math.floor(point.x), Math.floor(point.y)]

    cubicBezier bezierParameters..., (x, y) => @_paintPixel imageData, x, y

    # Draw the arrowhead.
    for segment in [0..2]
      if connection.sideEntry
        x = bezierParameters[6] - segment

        for y in [bezierParameters[7] - segment..bezierParameters[7] + segment]
          @_paintPixel imageData, x, y

      else
        y = bezierParameters[7] - segment

        for x in [bezierParameters[6] - segment..bezierParameters[6] + segment]
          @_paintPixel imageData, x, y

  _paintPixel: (imageData, x, y) ->
    return unless 0 <= x < imageData.width and 0 <= y < imageData.height

    pixelIndex = (x + y * imageData.width) * 4

    # Fill the pixel with line color (124, 140, 224).
    imageData.data[pixelIndex] = 124
    imageData.data[pixelIndex + 1] = 140
    imageData.data[pixelIndex + 2] = 224
    imageData.data[pixelIndex + 3] = 255

  _createBezierPoints: (connection) ->
    {start, end} = connection

    # Make the handle the shortest when a bit ahead of the start.
    deltaY = end.y - (start.y + 10)

    # Make the handle length grow faster going up.
    deltaY *= -2 if deltaY < 0

    # Make the handle half the vertical distance, but instead of linear growth, enforce a minimum length.
    minimumStartingHandleLength = 40
    handleLength = Math.pow(deltaY, 2) / (deltaY + minimumStartingHandleLength) * 0.5 + minimumStartingHandleLength

    # Smooth out the handle towards zero at small distances.
    distance = Math.pow(Math.abs(start.y - end.y) + Math.abs(start.x - end.x), 2)
    handleLength *= distance / (distance + 1000)

    handleLength = Math.max 10, Math.min 300, handleLength

    # Create bezier control points.
    controlStart =
      x: start.x
      y: start.y + handleLength

    if connection.sideEntry
      controlEnd =
        x: end.x - handleLength
        y: end.y

    else
      controlEnd =
        x: end.x
        y: end.y - handleLength

    [start, controlStart, controlEnd, end]
