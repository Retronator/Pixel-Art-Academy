AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Easel.Tools.Brush extends LOI.Assets.SpriteEditor.Tools.Tool
  extraToolClasses: -> 'brush'
  
  constructor: ->
    super arguments...

    @drawLine = new ReactiveField false
    @drawStraight = new ReactiveField false

    @lastCoordinates = new ReactiveField null
    @currentCoordinates = new ReactiveField null
    @lastStrokeCoordinates = new ReactiveField null
    @secondToLastStrokeCoordinates = new ReactiveField null
    @lockedCoordinate = new ReactiveField null

    @perfectAngleDegrees = new ReactiveField null

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
    @brushHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Brush

    @changedArea = new ReactiveField null

  onActivated: ->
    @processStroke()

    @_cursorChangesAutorun = @autorun (computation) =>
      # React to cursor changes.
      return unless @editor()?.cursor().cursorArea()
      Tracker.nonreactive => @processStroke()

  onDeactivated: ->
    @_cursorChangesAutorun.stop()

  cursorType: -> LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.AntiAliasedBrush

  infoText: ->
    return unless @drawLine()
    return unless angle = @perfectAngleDegrees()

    "#{angle}°"

  onKeyDown: (event) ->
    super arguments...

    if event.which is AC.Keys.shift
      # See if we've already started drawing.
      if @pointerState.mainButton
        # We're already mid-stroke so we want to detect in which direction to lock the coordinate.
        @lockedCoordinate null
        @drawStraight true

      else
        # When not drawing, shift triggers line drawing, but make sure no other modifiers are
        # pressed, since that would mean we're probably in the middle of executing a shortcut.
        keyboardState = AC.Keyboard.getState()

        unless keyboardState.isCommandOrControlDown() or keyboardState.isKeyDown AC.Keys.alt
          @drawLine true
          @updateChangedArea()

    else if @drawLine()
      # React to any modifier changes when line drawing.
      @updateChangedArea()

  onKeyUp: (event) ->
    super arguments...

    if event.which is AC.Keys.shift
      @drawStraight false
      @drawLine false
      @updateChangedArea()

    else if @drawLine()
      # React to any modifier changes when line drawing.
      @updateChangedArea()

  onPointerDown: (event) ->
    super arguments...

    # Register that the stroke has just started.
    @_strokeStarted = true

    @_strokeActive = true

    # If pointer down and move happen in the same frame (such as when using a stylus), allow the cursor to fully update.
    Tracker.afterFlush => @processStroke()

  onPointerUp: (event) ->
    super arguments...

    return unless @_strokeActive

    # End stroke.
    @lastStrokeCoordinates null
    @secondToLastStrokeCoordinates null

    @drawStraight false

    @updateChangedArea()

    assetData = @editor().assetData()
    @endStroke assetData

    @_strokeActive = false

  processStroke: ->
    currentCoordinates = @currentCoordinates()

    return unless cursorArea = @editor()?.cursor().cursorArea()

    if cursorArea.position
      newPixelCoordinates = _.clone cursorArea.position.centerCoordinates

      if @drawStraight()
        _.extend newPixelCoordinates, @lockedCoordinate()

    # Update coordinates if they are new.
    unless EJSON.equals currentCoordinates, newPixelCoordinates
      @currentCoordinates newPixelCoordinates

    @updateChangedArea()

  updateChangedArea: ->
    return
    
    # Calculate which pixels the tool would fill.
    return unless currentPixelCoordinates = @currentCoordinates()
    currentPixelCoordinates = new THREE.Vector2().copy currentPixelCoordinates
    lastPixelCoordinates = new THREE.Vector2().copy @lastCoordinates() or currentPixelCoordinates
    lastStrokeCoordinates = new THREE.Vector2().copy @lastStrokeCoordinates() or currentPixelCoordinates
    secondToLastStrokeCoordinates = new THREE.Vector2().copy @secondToLastStrokeCoordinates() or lastStrokeCoordinates

    keyboardState = AC.Keyboard.getState()
    pixelCoordinates = []

    drawStraight = @drawStraight()

    if @pointerState.mainButton and drawStraight
      unless lockedCoordinate = @lockedCoordinate()
        # Calculate which direction to lock to.
        if currentPixelCoordinates.x is lastPixelCoordinates.x
          # Lock to vertical straight lines.
          lockedCoordinate = x: lastPixelCoordinates.x

        else
          lockedCoordinate = y: lastPixelCoordinates.y

        @lockedCoordinate lockedCoordinate

    if @drawLine()
      if keyboardState.isMetaDown()
        # Draw perfect pixel art line.
        pixelCoordinates = @perfectLine lastPixelCoordinates, currentPixelCoordinates

        # Match current coordinates to the ending perfect coordinates.
        @currentCoordinates _.last pixelCoordinates

      else
        @perfectAngleDegrees null

        # Draw bresenham line from last coordinates (which persist after end of stroke).
        # Bresenham.line lastPixelCoordinates.x, lastPixelCoordinates.y, currentPixelCoordinates.x, currentPixelCoordinates.y, (x, y) => pixelCoordinates.push {x, y}

    else
      # Apply locked coordinate.
      if drawStraight
        # Draw bresenham line from last stroke coordinates (which resets after end of stroke).
        # Bresenham.line lastStrokeCoordinates.x, lastStrokeCoordinates.y, currentPixelCoordinates.x, currentPixelCoordinates.y, (x, y) => pixelCoordinates.push {x, y}

      else
        # Draw bezier curve from last stroke coordinates (which resets after end of stroke).
        tangentDirection = new THREE.Vector2().subVectors(currentPixelCoordinates, secondToLastStrokeCoordinates).normalize()
        midPoint = lastStrokeCoordinates.clone().add(currentPixelCoordinates).multiplyScalar(0.5)

        # Project mid-point to the tangent going from last point.
        ray = new THREE.Ray lastStrokeCoordinates, tangentDirection
        bezierMidPoint = new THREE.Vector2
        ray.closestPointToPoint midPoint, bezierMidPoint
        bezierMidPoint.round()

        # Bresenham.quadBezier lastStrokeCoordinates.x, lastStrokeCoordinates.y, bezierMidPoint.x, bezierMidPoint.y, currentPixelCoordinates.x, currentPixelCoordinates.y, (x, y) => pixelCoordinates.push {x, y}

    # Apply the brush mask to coordinates.
    cursorArea = @editor().cursor().cursorArea()
    offset = cursorArea.position.centerOffset
    brushCoordinates = {}

    for pixel in pixelCoordinates
      for column, x in cursorArea.shape
        for value, y in column when value
          brushX = pixel.x - offset + x
          brushY = pixel.y - offset + y
          brushCoordinates[brushX] ?= {}
          brushCoordinates[brushX][brushY] = x: brushX, y: brushY

    # Collect created pixels.
    pixelCoordinates = []

    for x, row of brushCoordinates
      for y, pixel of row
        pixelCoordinates.push pixel

    # TODO: Apply symmetry.
    # symmetryXOrigin = @options.editor().symmetryXOrigin?()
    #if symmetryXOrigin?
    #  mirroredX = -@pointerState.x + 2 * symmetryXOrigin
    #  xCoordinates.push [mirroredX, -1]
  
    assetData = @editor().assetData()
    
    @pixels @createPixelsFromCoordinates assetData, pixelCoordinates
    @applyTool()

  applyTool: ->
    return unless @pointerState.mainButton

    assetData = @editor().assetData()

    layerIndex = @paintHelper.layerIndex()
    layer = assetData.layers?[layerIndex]

    layerOrigin =
      x: layer?.origin?.x or 0
      y: layer?.origin?.y or 0

    absolutePixels = @pixels()
    relativePixels = []

    for absolutePixel in absolutePixels
      # If we have fixed bounds, make sure we're inside.
      if assetData.bounds?.fixed
        continue unless assetData.bounds.left <= absolutePixel.x <= assetData.bounds.right and assetData.bounds.top <= absolutePixel.y <= assetData.bounds.bottom

      # Pixel must be in relative coordinates.
      relativePixel = _.clone absolutePixel
      relativePixel.x -= layerOrigin.x
      relativePixel.y -= layerOrigin.y
      
      relativePixels.push relativePixel

    @applyPixels assetData, layerIndex, relativePixels, @_strokeStarted

    # Save start of current stroke segment to allow smoothing.
    @secondToLastStrokeCoordinates @lastStrokeCoordinates()

    # Save last absolute pixel as the end of the stroke.
    currentPixelCoordinates = @currentCoordinates()
    @lastCoordinates currentPixelCoordinates
    @lastStrokeCoordinates currentPixelCoordinates

  startOfStrokeProcessed: ->
    @_strokeStarted = false

  applyPixels: (assetData, layerIndex, relativePixels, strokeStarted) ->
    # Override to process new pixels being added to the stroke.

  endStroke: (assetData) ->
    # Override to process the end of the stroke.
