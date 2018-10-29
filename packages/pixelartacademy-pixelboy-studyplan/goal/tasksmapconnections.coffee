PAA = PixelArtAcademy

{cubicBezier} = require 'bresenham-zingl'

class PAA.PixelBoy.Apps.StudyPlan.Goal.TasksMapConnections
  @draw: (goalComponent) ->
    return unless goalComponent.goalTasks.length
    
    $canvas = goalComponent.$('.tasks-map .connections-canvas')
    canvas = $canvas[0]
    context = canvas.getContext '2d'
    
    size = goalComponent.tasksMapSize()

    canvas.width = size.width
    canvas.height = size.height

    imageData = context.getImageData 0, 0, canvas.width, canvas.height

    for goalTask in goalComponent.goalTasks
      @_drawGoalTask goalComponent, goalTask, imageData

    context.putImageData imageData, 0, 0

  @_drawGoalTask: (goalComponent, goalTask, imageData) ->
    # Draw a line across dummy tasks.
    unless goalTask.task
      y = goalTask.entryPoint.y

      endX = if goalTask.endTask then imageData.width - 4 else goalTask.exitPoint.x
      
      for x in [goalTask.entryPoint.x..endX]
        @_paintPixel imageData, x, y

    # Draw curves from all predecessors.
    for predecessor in goalTask.predecessors
      bezierPoints = @_createBezierPoints predecessor.exitPoint, goalTask.entryPoint, goalComponent.levelGap

      bezierParameters = _.flatten _.map bezierPoints, (point) => [point.x, point.y]

      cubicBezier bezierParameters..., (x, y) => @_paintPixel imageData, x, y

  @_paintPixel: (imageData, x, y) ->
    return unless 0 <= x < imageData.width and 0 <= y < imageData.height

    pixelIndex = (x + y * imageData.width) * 4

    # Fill the pixel with line color (124, 180, 212).
    imageData.data[pixelIndex] = 124
    imageData.data[pixelIndex + 1] = 180
    imageData.data[pixelIndex + 2] = 212
    imageData.data[pixelIndex + 3] = 255

  @_createBezierPoints: (start, end, handleLength) ->
    # Create bezier control points.
    controlStart =
      x: start.x + handleLength
      y: start.y

    controlEnd =
      x: end.x - handleLength
      y: end.y

    [start, controlStart, controlEnd, end]
