AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan.Blueprint.Flowchart extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.Blueprint.Flowchart'
  @register @id()

  constructor: (@blueprint) ->
    super

    @redrawDependency = new Tracker.Dependency

    @$imageCanvas = $('<img>')
    @imageCanvas = @$imageCanvas[0]

    @$pixelCanvas = $('<canvas>')
    @pixelCanvas = @$pixelCanvas[0]
    @pixelContext = @pixelCanvas.getContext '2d'

  svgWidth: ->
    @blueprint.camera().viewportBounds.width() * @blueprint.display.scale()

  svgHeight: ->
    @blueprint.camera().viewportBounds.height() * @blueprint.display.scale()

  width: ->
    @blueprint.camera().viewportBounds.width()

  height: ->
    @blueprint.camera().viewportBounds.height()

  viewboxAttribute: ->
    @redraw()

    bounds = @blueprint.camera().viewportBounds
    viewBox: "#{Math.floor bounds.left()} #{Math.floor bounds.top()} #{bounds.width()} #{bounds.height()}"

  connections: ->
    @redraw()

    @blueprint.connections()

  connectionPath: ->
    @redraw()

    {start, end} = @currentData()

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

    "M#{start.x},#{start.y} C#{controlStart.x},#{controlStart.y} #{controlEnd.x},#{controlEnd.y} #{end.x},#{end.y}"

  redraw: ->
    # After the html has had time to update, copy it to pixel canvas.
    Meteor.setTimeout =>
      svgSource = @$('.svg-canvas')[0].outerHTML

      # Create the image with the SVG content.
      @$imageCanvas.attr src: "data:image/svg+xml;utf8,#{svgSource}"

      @redrawDependency.changed()
    ,
      0

  drawToContext: (context) ->
    @redrawDependency.depend()

    # Render the image to a canvas to transform vector content to raster.
    @pixelCanvas.width = @width()
    @pixelCanvas.height = @height()
    @pixelContext.drawImage @imageCanvas, 0, 0, @pixelCanvas.width, @pixelCanvas.height

    # Render the raster data into the canvas.
    context.setTransform 1, 0, 0, 1, 0, 0
    context.imageSmoothingEnabled = false
    context.drawImage @pixelCanvas, 0, 0, context.canvas.width, context.canvas.height
