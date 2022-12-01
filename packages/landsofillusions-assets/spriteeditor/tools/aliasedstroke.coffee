AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

Bresenham = require('bresenham-zingl')

_currentPixelCoordinates = new THREE.Vector2
_lastPixelCoordinates = new THREE.Vector2
_lastStrokeCoordinates = new THREE.Vector2
_secondToLastStrokeCoordinates = new THREE.Vector2
_tangentDirection = new THREE.Vector2
_ray = new THREE.Ray
_bezierMidPoint = new THREE.Vector2

_pixelCoordinates = null
_pixelCoordinatesLength = 0

_createPixelCoordinates = (width, height) ->
  pixelCoordinatesCapacity = (width + height) * 2
  
  unless _pixelCoordinates and _pixelCoordinates.length >= pixelCoordinatesCapacity
    _pixelCoordinates = new Int16Array pixelCoordinatesCapacity
    
_clearPixelCoordinates = ->
  _pixelCoordinatesLength = 0

_addPixelCoordinate = (x, y) ->
  _pixelCoordinates[_pixelCoordinatesLength] = x
  _pixelCoordinates[_pixelCoordinatesLength + 1] = y
  _pixelCoordinatesLength += 2
  
_strokeMask = null
_strokeMaskWidth = 0
_strokeMaskHeight = 0

_createStrokeMask = (width, height) ->
  _strokeMaskWidth = width
  _strokeMaskHeight = height
  strokeMaskCapacity = width * height
  unless _strokeMask and _strokeMask.length >= strokeMaskCapacity
    _strokeMask = new Uint8Array strokeMaskCapacity
    
_clearStrokeMask = ->
  _strokeMask.fill 0
  
_addStrokeMask = (x, y) ->
  _strokeMask[x + y * _strokeMaskWidth] = 1

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
    # Create a pixel coordinates array large enough to hold the entire stroke.
    assetData = @editor().assetData()
    _createPixelCoordinates assetData.bounds.width, assetData.bounds.height
    _createStrokeMask assetData.bounds.width, assetData.bounds.height
    
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
  
    segmentLengthIndex = 0
    segmentLeft = segmentLengths[segmentLengthIndex]

    while lengthLeft and sideLeft
      _addPixelCoordinate currentPixel.x, currentPixel.y

      # Mark progress along segment and length.
      segmentLeft--
      lengthLeft--

      # Move ahead along length.
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
    _currentPixelCoordinates.copy currentPixelCoordinates
    _lastPixelCoordinates.copy @lastPixelCoordinates() or _currentPixelCoordinates
    _lastStrokeCoordinates.copy @lastStrokeCoordinates() or _currentPixelCoordinates
    _secondToLastStrokeCoordinates.copy @secondToLastStrokeCoordinates() or _lastStrokeCoordinates

    keyboardState = AC.Keyboard.getState()
    _clearPixelCoordinates()

    drawStraight = @drawStraight()

    if @mouseState.leftButton and drawStraight
      unless lockedCoordinate = @lockedCoordinate()
        # Calculate which direction to lock to.
        if _currentPixelCoordinates.x is _lastPixelCoordinates.x
          # Lock to vertical straight lines.
          lockedCoordinate = x: _lastPixelCoordinates.x

        else
          lockedCoordinate = y: _lastPixelCoordinates.y

        @lockedCoordinate lockedCoordinate

    if @drawLine()
      if keyboardState.isMetaDown()
        # Draw perfect pixel art line.
        @perfectLine _lastPixelCoordinates, _currentPixelCoordinates

        # Match current coordinates to the ending perfect coordinates.
        @currentPixelCoordinates _.last pixelCoordinates

      else
        @perfectLineRatio null

        # Draw bresenham line from last coordinates (which persist after end of stroke).
        _clearPixelCoordinates()
        Bresenham.line _lastPixelCoordinates.x, _lastPixelCoordinates.y, _currentPixelCoordinates.x, _currentPixelCoordinates.y, (x, y) => _addPixelCoordinate x, y

    else
      # Apply locked coordinate.
      if drawStraight
        # Draw bresenham line from last stroke coordinates (which resets after end of stroke).
        Bresenham.line _lastStrokeCoordinates.x, _lastStrokeCoordinates.y, _currentPixelCoordinates.x, _currentPixelCoordinates.y, (x, y) => _addPixelCoordinate x, y

      else
        # Draw bezier curve from last stroke coordinates (which resets after end of stroke).
        _tangentDirection.subVectors(_currentPixelCoordinates, _secondToLastStrokeCoordinates).normalize()
        midPoint = _lastStrokeCoordinates.clone().add(_currentPixelCoordinates).multiplyScalar(0.5)

        # Project mid-point to the tangent going from last point.
        _ray.set _lastStrokeCoordinates, _tangentDirection
        _ray.closestPointToPoint midPoint, _bezierMidPoint
        _bezierMidPoint.round()

        Bresenham.quadBezier _lastStrokeCoordinates.x, _lastStrokeCoordinates.y, _bezierMidPoint.x, _bezierMidPoint.y, _currentPixelCoordinates.x, _currentPixelCoordinates.y, (x, y) => _addPixelCoordinate x, y

    # Apply the brush mask to coordinates.
    cursorArea = @editor().cursor().cursorArea()
    offset = cursorArea.position.centerOffset
    assetData = @editor().assetData()
    boundsLeft = assetData.bounds.left
    boundsTop = assetData.bounds.top
    boundsWidth = assetData.bounds.width
    boundsHeight = assetData.bounds.height
    
    _clearStrokeMask()

    for column, x in cursorArea.aliasedShape
      for value, y in column when value
        for pixelCoordinateIndex in [0..._pixelCoordinatesLength] by 2
          brushX = _pixelCoordinates[pixelCoordinateIndex] - offset + x - boundsLeft
          brushY = _pixelCoordinates[pixelCoordinateIndex + 1] - offset + y - boundsTop
          _addStrokeMask brushX, brushY if 0 <= brushX < boundsWidth and 0 <= brushY < boundsHeight

    # TODO: Apply symmetry.
    # symmetryXOrigin = @options.editor().symmetryXOrigin?()
    #if symmetryXOrigin?
    #  mirroredX = -@mouseState.x + 2 * symmetryXOrigin
    #  xCoordinates.push [mirroredX, -1]

    @pixels @createPixelsFromCoordinates assetData, _strokeMask
    
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

  createPixelsFromCoordinates: (strokeMask) ->
    throw new AE.NotImplementedException "Provide a method that creates full pixel data out of the stroke mask."
    
  applyPixels: (assetData, layerIndex, relativePixels, strokeStarted) ->
    # Override to process new pixels being added to the stroke.

  endStroke: (assetData) ->
    # Override to process the end of the stroke.
