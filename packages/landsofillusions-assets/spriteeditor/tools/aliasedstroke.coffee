AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

Bresenham = require('bresenham-zingl')

class LOI.Assets.SpriteEditor.Tools.AliasedStroke extends LOI.Assets.SpriteEditor.Tools.Tool
  # cleanLine: boolean whether to maintain a clean line with consistent width
  # drawPreview: boolean whether to always draw preview of the pixels to be applied
  # fractionalPerfectLines: boolean whether to allow 3:2 and 5:2 lines
  constructor: ->
    super arguments...

    @drawLine = new ReactiveField false
    @drawStraight = new ReactiveField false

    @lastPixelCoordinates = new ReactiveField null
    @currentPixelCoordinates = new ReactiveField null
    @lastStrokeCoordinates = new ReactiveField null
    @secondToLastStrokeCoordinates = new ReactiveField null
    @lockedCoordinate = new ReactiveField null

    @perfectLineRatio = new ReactiveField null

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
    @brushHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Brush

    @pixels = new ReactiveField null
    
    # Request realtime updates when actively changing pixels.
    @realtimeUpdating = new ReactiveField false

  onActivated: ->
    @processStroke()

    @_previewActive = false

    @_cursorChangesAutorun = @autorun (computation) =>
      # React to cursor changes.
      return unless @editor()?.cursor().cursorArea().aliasedShape
      Tracker.nonreactive => @processStroke()

    @_updatePreviewAutorun = @autorun (computation) =>
      return unless editor = @editor()

      # Show preview when we're drawing a line and mouse is on the canvas.
      preview = (@data.get('drawPreview') or @drawLine()) and editor.mouse().pixelCoordinate()

      if preview
        # Update preview pixels.
        editor.operationPreview().pixels @pixels()

      else if @_previewActive
        # Remove pixels, since we were the ones providing them.
        editor.operationPreview().pixels []

      @_previewActive = preview

  onDeactivated: ->
    @_cursorChangesAutorun.stop()
    @_updatePreviewAutorun.stop()
    @editor().operationPreview().pixels []

  cursorType: -> LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.AliasedBrush
  
  infoText: ->
    return unless @drawLine()
    return unless ratio = @perfectLineRatio()

    "#{ratio[0]}:#{ratio[1]}"

  perfectLine: (start, end) ->
    dx = end.x - start.x
    dy = end.y - start.y

    width = Math.abs(dx) + 1
    height = Math.abs(dy) + 1

    if width > height
      ratio = width / height

    else
      ratio = height / width
      vertical = true

    if ratio < 3 and @data.get 'fractionalPerfectLines'
      doubleRatio = Math.round ratio * 2
      segmentLengths = [Math.ceil(doubleRatio / 2), Math.floor(doubleRatio / 2)]

      if segmentLengths[0] is segmentLengths[1]
        denominator = 1
        numerator = segmentLengths[0]

      else
        denominator = 2
        numerator = segmentLengths[0] + segmentLengths[1]

    else
      numerator = Math.round ratio
      denominator = 1
      segmentLengths = [numerator]

    if width > 1 and height > 1
      if vertical
        @perfectLineRatio [denominator, numerator]

      else
        @perfectLineRatio [numerator, denominator]

    else
      # Don't write the ratio for straight lines.
      @perfectLineRatio null

    sx = Math.sign dx
    sy = Math.sign dy

    lengthLeft = Math.max width, height
    sideLeft = Math.min width, height

    currentPixel = _.pick start, ['x', 'y']
    pixels = []
    segmentLengthIndex = 0
    segmentLeft = segmentLengths[segmentLengthIndex]

    while lengthLeft and sideLeft
      pixels.push currentPixel

      # Mark progress along segment and length.
      segmentLeft--
      lengthLeft--

      # Move ahead along length.
      currentPixel = _.clone currentPixel

      if vertical
        currentPixel.y += sy

      else
        currentPixel.x += sx

      continue if segmentLeft

      # Step sideways.
      if vertical
        currentPixel.x += sx

      else
        currentPixel.y += sy

      sideLeft--
      segmentLengthIndex = (segmentLengthIndex + 1) % segmentLengths.length
      segmentLeft = segmentLengths[segmentLengthIndex]

    pixels

  onKeyDown: (event) ->
    super arguments...

    if event.which is AC.Keys.shift
      # See if we've already started drawing.
      if @mouseState.leftButton
        # We're already mid-stroke so we want to detect in which direction to lock the coordinate.
        @lockedCoordinate null
        @drawStraight true

      else
        # When not drawing, shift triggers line drawing, but make sure no other modifiers are
        # pressed, since that would mean we're probably in the middle of executing a shortcut.
        keyboardState = AC.Keyboard.getState()

        unless keyboardState.isCommandOrControlDown() or keyboardState.isKeyDown AC.Keys.alt
          @drawLine true
          @realtimeUpdating true
          @updatePixels()

    else if @drawLine()
      # React to any modifier changes when line drawing.
      @updatePixels()

  onKeyUp: (event) ->
    super arguments...

    if event.which is AC.Keys.shift
      @drawStraight false
      @drawLine false
      @realtimeUpdating false
      @updatePixels()

    else if @drawLine()
      # React to any modifier changes when line drawing.
      @updatePixels()

  onMouseDown: (event) ->
    super arguments...

    # Register that the stroke has just started.
    @_strokeStarted = true

    @_strokeActive = true
    @realtimeUpdating true

    # If mouse down and move happen in the same frame (such as when using a stylus), allow the cursor to fully update.
    Tracker.afterFlush => @processStroke()

  onMouseUp: (event) ->
    super arguments...

    return unless @_strokeActive

    # End stroke.
    @lastStrokeCoordinates null
    @secondToLastStrokeCoordinates null

    @drawStraight false

    @updatePixels()

    assetData = @editor().assetData()
    @endStroke assetData

    @_strokeActive = false
    @realtimeUpdating false

  processStroke: ->
    currentPixelCoordinates = @currentPixelCoordinates()

    return unless cursorArea = @editor()?.cursor().cursorArea()

    if cursorArea.position
      newPixelCoordinates = _.clone cursorArea.position.centerCoordinates

      if @drawStraight()
        _.extend newPixelCoordinates, @lockedCoordinate()

    # Update coordinates if they are new.
    unless EJSON.equals currentPixelCoordinates, newPixelCoordinates
      @currentPixelCoordinates newPixelCoordinates

    @updatePixels()

  updatePixels: ->
    # Calculate which pixels the tool would fill.
    return unless currentPixelCoordinates = @currentPixelCoordinates()
    currentPixelCoordinates = new THREE.Vector2().copy currentPixelCoordinates
    lastPixelCoordinates = new THREE.Vector2().copy @lastPixelCoordinates() or currentPixelCoordinates
    lastStrokeCoordinates = new THREE.Vector2().copy @lastStrokeCoordinates() or currentPixelCoordinates
    secondToLastStrokeCoordinates = new THREE.Vector2().copy @secondToLastStrokeCoordinates() or lastStrokeCoordinates

    keyboardState = AC.Keyboard.getState()
    pixelCoordinates = []

    drawStraight = @drawStraight()

    if @mouseState.leftButton and drawStraight
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
        @currentPixelCoordinates _.last pixelCoordinates

      else
        @perfectLineRatio null

        # Draw bresenham line from last coordinates (which persist after end of stroke).
        Bresenham.line lastPixelCoordinates.x, lastPixelCoordinates.y, currentPixelCoordinates.x, currentPixelCoordinates.y, (x, y) => pixelCoordinates.push {x, y}

    else
      # Apply locked coordinate.
      if drawStraight
        # Draw bresenham line from last stroke coordinates (which resets after end of stroke).
        Bresenham.line lastStrokeCoordinates.x, lastStrokeCoordinates.y, currentPixelCoordinates.x, currentPixelCoordinates.y, (x, y) => pixelCoordinates.push {x, y}

      else
        # Draw bezier curve from last stroke coordinates (which resets after end of stroke).
        tangentDirection = new THREE.Vector2().subVectors(currentPixelCoordinates, secondToLastStrokeCoordinates).normalize()
        midPoint = lastStrokeCoordinates.clone().add(currentPixelCoordinates).multiplyScalar(0.5)

        # Project mid-point to the tangent going from last point.
        ray = new THREE.Ray lastStrokeCoordinates, tangentDirection
        bezierMidPoint = new THREE.Vector2
        ray.closestPointToPoint midPoint, bezierMidPoint
        bezierMidPoint.round()

        Bresenham.quadBezier lastStrokeCoordinates.x, lastStrokeCoordinates.y, bezierMidPoint.x, bezierMidPoint.y, currentPixelCoordinates.x, currentPixelCoordinates.y, (x, y) => pixelCoordinates.push {x, y}

    # Apply the brush mask to coordinates.
    cursorArea = @editor().cursor().cursorArea()
    offset = cursorArea.position.centerOffset
    brushCoordinates = {}

    for pixel in pixelCoordinates
      for column, x in cursorArea.aliasedShape
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
    #  mirroredX = -@mouseState.x + 2 * symmetryXOrigin
    #  xCoordinates.push [mirroredX, -1]

    @pixels @createPixelsFromCoordinates pixelCoordinates
    @applyTool()

  applyTool: ->
    return unless @mouseState.leftButton

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
    currentPixelCoordinates = @currentPixelCoordinates()
    @lastPixelCoordinates currentPixelCoordinates
    @lastStrokeCoordinates currentPixelCoordinates

  startOfStrokeProcessed: ->
    @_strokeStarted = false

  createPixelsFromCoordinates: (coordinates) ->
    # Override to create full pixel data out of stroke coordinates.
    coordinates
    
  applyPixels: (assetData, layerIndex, relativePixels, strokeStarted) ->
    # Override to process new pixels being added to the stroke.

  endStroke: (assetData) ->
    # Override to process the end of the stroke.
