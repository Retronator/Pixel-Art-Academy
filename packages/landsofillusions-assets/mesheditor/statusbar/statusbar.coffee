AE = Artificial.Everywhere
AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.StatusBar extends FM.View
  @id: -> "LandsOfIllusions.Assets.MeshEditor.StatusBar"
  @register @id()

  template: -> @constructor.id()

  onCreated: ->
    super arguments...

    @meshCanvas = new ComputedField =>
      @interface.getEditorForActiveFile()
    ,
      (a, b) => a is b

    @cameraAngle = new ComputedField =>
      @meshCanvas()?.cameraAngle()

    @raycaster = new ComputedField =>
      @cameraAngle()?.getRaycaster x: 0, y: 0

  mouseCoordinates: ->
    return unless meshCanvas = @meshCanvas()

    mouse = meshCanvas.mouse()
    return unless pixelCoordinate = mouse.pixelCoordinate()

    "#{pixelCoordinate.x}, #{pixelCoordinate.y}"

  mouseCoordinatesVerbose: ->
    return unless meshCanvas = @meshCanvas()
    mouse = meshCanvas.mouse()

    return unless mouse.windowCoordinate()

    windowCoordinate = @_coordinateString mouse.windowCoordinate()
    displayCoordinate = @_coordinateString mouse.displayCoordinate()
    canvasCoordinate = @_coordinateString mouse.canvasCoordinate()
    pixelCoordinate = @_coordinateString mouse.pixelCoordinate()

    "window: #{windowCoordinate}, display: #{displayCoordinate}, canvas: #{canvasCoordinate}, pixel: #{pixelCoordinate}"

  _coordinateString: (coordinate, decimalPlaces) ->
    xPart = @_roundCoordinate coordinate.x, decimalPlaces
    yPart = ", #{@_roundCoordinate coordinate.y, decimalPlaces}"
    zPart = if coordinate.z? then ", #{@_roundCoordinate coordinate.z, decimalPlaces}" else ""

    "(#{xPart}#{yPart}#{zPart})"

  _roundCoordinate: (value, decimalPlaces) ->
    return value unless decimalPlaces?
    value.toFixed decimalPlaces

  projectedCoordinates: ->
    return unless meshCanvas = @meshCanvas()
    return unless cameraAngle = @cameraAngle()
    return unless raycaster = @raycaster()

    mouse = meshCanvas.mouse()
    return unless canvasCoordinate = mouse.canvasCoordinate()

    cameraAngle.updateRaycaster raycaster, canvasCoordinate
    scene = meshCanvas.sceneHelper().scene()
    intersections = raycaster.intersectObjects scene.children, true
    return unless intersection = intersections[0]

    @_coordinateString intersection.point, 2

  projectedCoordinatesVerbose: ->
    return unless meshCanvas = @meshCanvas()
    return unless cameraAngle = @cameraAngle()
    return unless raycaster = @raycaster()

    mouse = meshCanvas.mouse()
    return unless canvasCoordinate = mouse.canvasCoordinate()

    cameraAngle.updateRaycaster raycaster, canvasCoordinate
    scene = meshCanvas.sceneHelper().scene()
    intersections = raycaster.intersectObjects scene.children, true
    return unless intersection = intersections[0]

    projectedPosition = @_coordinateString intersection.point, 2
    unprojectedCoordinate = @_coordinateString cameraAngle.unprojectPoint(intersection.point), 2

    "world: #{projectedPosition} canvas: #{unprojectedCoordinate}"
