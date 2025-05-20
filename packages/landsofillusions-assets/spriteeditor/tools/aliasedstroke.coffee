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

_strokeMask = new LOI.Assets.SpriteEditor.Tools.AliasedStrokeMask

class LOI.Assets.SpriteEditor.Tools.AliasedStroke extends LOI.Assets.SpriteEditor.Tools.Tool
  @requiredButtonOnActivate: ->
    # Override with the button (or an array of alternatives) that needs to be pressed to start the stroke on activate.
    null
    
  @createRelativePixels: (assetData, layer, absolutePixels)->
    layerOrigin =
      x: layer?.origin?.x or 0
      y: layer?.origin?.y or 0

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
    
    relativePixels
  
  # TODO: cleanLine: boolean whether to maintain a clean line with consistent width
  # drawPreview: boolean whether to always draw preview of the pixels to be applied
  constructor: ->
    super arguments...

    @drawLine = new ReactiveField false
    @drawStraight = new ReactiveField false
    @strokeActive = new ReactiveField false

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
    
    # Reset last pixel coordinates whenever the active file changes.
    @autorun (computation) =>
      @interface.activeFileId()
      @lastPixelCoordinates null

  onActivated: ->
    # Create stroke mask to match asset bounds.
    @_recreateStrokeMaskAutorun = @autorun (computation) =>
      return unless assetData = @editor()?.assetData()
      _strokeMask.initialize assetData.bounds.width, assetData.bounds.height
    
    @processStroke()

    @_previewActive = false

    @_cursorChangesAutorun = @autorun (computation) =>
      # React to cursor changes.
      return unless @editor()?.cursor().cursorArea().aliasedShape
      Tracker.nonreactive => @processStroke()

    @_updatePreviewAutorun = @autorun (computation) =>
      return unless editor = @editor()

      # Show preview when we're drawing a line and pointer is on the canvas.
      preview = (@data.get('drawPreview') or @drawLine()) and editor.pointer().pixelCoordinate()

      if preview
        # Update preview pixels.
        editor.operationPreview().pixels @pixels()

      else if @_previewActive
        # Remove pixels, since we were the ones providing them.
        editor.operationPreview().pixels []

      @_previewActive = preview

    # Also start the stroke if the required button is pressed.
    requiredButton = @constructor.requiredButtonOnActivate()
    return unless requiredButton
    
    requiredButtons = if _.isArray requiredButton then requiredButton else [requiredButton]
    return unless _.some requiredButtons, (requiredButton) => AC.Pointer.getState().isButtonDown requiredButton
  
    @startStroke()

  onDeactivated: ->
    @finalizeStroke()
    
    @drawStraight false
    @drawLine false
    @realtimeUpdating false
    
    @_recreateStrokeMaskAutorun.stop()
    @_cursorChangesAutorun.stop()
    @_updatePreviewAutorun.stop()
    @editor().operationPreview().pixels [] if @_previewActive

  cursorType: -> LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.AliasedBrush
  
  infoText: ->
    return unless @drawLine()
    return unless ratio = @perfectLineRatio()

    "#{ratio[1]}:#{ratio[0]}"

  perfectLine: (start, end) ->
    line = @interface.getOperator LOI.Assets.SpriteEditor.Tools.Line
    fractional = line.data.get 'fractionalPerfectLines'
    
    {pixels, ratio} = LOI.Assets.SpriteEditor.Tools.Line.perfectLine start, end, fractional
    
    @perfectLineRatio ratio
    
    for pixel in pixels
      _strokeMask.addPixelCoordinate pixel.x, pixel.y
    
    pixels

  isEngaged: -> @strokeActive()
  
  onKeyDown: (event) ->
    super arguments...

    if event.which is AC.Keys.shift
      # See if we've already started drawing.
      if @strokeActive()
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
          @processStroke()

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
      # Note: We want to process the stroke and not just update the pixels since a perfect line
      # changes the current pixel coordinates and they need to be reset to the actual cursor position.
      @processStroke()

  onPointerDown: (event) ->
    super arguments...
    
    # Only react to the main button.
    return if event.button
    
    @startStroke()
    
  startStroke: ->
    # Only react when the pointer has a valid position.
    return unless @editor()?.pointer().canvasCoordinate()

    # Register that the stroke has just started.
    @_strokeStarted = true

    @strokeActive true
    @realtimeUpdating true

    # If pointer down and move happen in the same frame (such as when using a stylus), allow the cursor to fully update.
    Tracker.afterFlush => @processStroke()

  onPointerUp: (event) ->
    super arguments...
    
    @finalizeStroke()

  finalizeStroke: ->
    return unless @strokeActive()

    # End stroke.
    @lastStrokeCoordinates null
    @secondToLastStrokeCoordinates null

    @drawStraight false

    assetData = @editor().assetData()
    @endStroke assetData

    @strokeActive false
    @realtimeUpdating false

    # Update pixels to take account of new starting coordinates for line drawing.
    @updatePixels()
  
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
    _strokeMask.reset()

    drawStraight = @drawStraight()

    if @strokeActive() and drawStraight
      unless lockedCoordinate = @lockedCoordinate()
        # Calculate which direction to lock to.
        if _currentPixelCoordinates.x is _lastPixelCoordinates.x
          # Lock to vertical straight lines.
          lockedCoordinate = x: _lastPixelCoordinates.x

        else
          lockedCoordinate = y: _lastPixelCoordinates.y

        @lockedCoordinate lockedCoordinate

    if @drawLine()
      if keyboardState.isCommandOrControlDown()
        # Draw perfect pixel art line.
        pixels = @perfectLine _lastPixelCoordinates, _currentPixelCoordinates

        # Match current coordinates to the ending perfect coordinates.
        @currentPixelCoordinates _.last pixels

      else
        @perfectLineRatio null

        # Draw bresenham line from last coordinates (which persist after end of stroke). To assure
        # consistency between drawing lines from both directions, we always draw from top to bottom.
        if _lastPixelCoordinates.y < _currentPixelCoordinates.y
          Bresenham.line _lastPixelCoordinates.x, _lastPixelCoordinates.y, _currentPixelCoordinates.x, _currentPixelCoordinates.y, (x, y) => _strokeMask.addPixelCoordinate x, y
          
        else
          Bresenham.line _currentPixelCoordinates.x, _currentPixelCoordinates.y, _lastPixelCoordinates.x, _lastPixelCoordinates.y, (x, y) => _strokeMask.addPixelCoordinate x, y

    else
      # Apply locked coordinate.
      if drawStraight
        # Draw bresenham line from last stroke coordinates (which resets after end of stroke).
        Bresenham.line _lastStrokeCoordinates.x, _lastStrokeCoordinates.y, _currentPixelCoordinates.x, _currentPixelCoordinates.y, (x, y) => _strokeMask.addPixelCoordinate x, y

      else
        # Draw bezier curve from last stroke coordinates (which resets after end of stroke).
        _tangentDirection.subVectors(_currentPixelCoordinates, _secondToLastStrokeCoordinates).normalize()
        midPoint = _lastStrokeCoordinates.clone().add(_currentPixelCoordinates).multiplyScalar(0.5)

        # Project mid-point to the tangent going from last point.
        _ray.set _lastStrokeCoordinates, _tangentDirection
        _ray.closestPointToPoint midPoint, _bezierMidPoint
        _bezierMidPoint.round()

        Bresenham.quadBezier _lastStrokeCoordinates.x, _lastStrokeCoordinates.y, _bezierMidPoint.x, _bezierMidPoint.y, _currentPixelCoordinates.x, _currentPixelCoordinates.y, (x, y) => _strokeMask.addPixelCoordinate x, y

    # Apply the cursor area to the stroke mask.
    cursorArea = @editor().cursor().cursorArea()
    assetData = @editor().assetData()
    
    _strokeMask.generate cursorArea, assetData.bounds

    @pixels @createPixelsFromStrokeMask assetData, _strokeMask
    
    @applyTool()

  applyTool: ->
    return unless @strokeActive()

    assetData = @editor().assetData()
    layerIndex = @paintHelper.layerIndex()
    layer = assetData.layers?[layerIndex]
    
    relativePixels = @constructor.createRelativePixels assetData, layer, @pixels()

    @applyPixels assetData, layerIndex, relativePixels, @_strokeStarted

    # Save start of current stroke segment to allow smoothing.
    @secondToLastStrokeCoordinates @lastStrokeCoordinates()

    # Save last absolute pixel as the end of the stroke.
    currentPixelCoordinates = @currentPixelCoordinates()
    @lastPixelCoordinates currentPixelCoordinates
    @lastStrokeCoordinates currentPixelCoordinates

  startOfStrokeProcessed: ->
    @_strokeStarted = false

  createPixelsFromStrokeMask: (assetData, strokeMask) ->
    throw new AE.NotImplementedException "Provide a method that creates full pixel data out of the stroke mask."
    
  applyPixels: (assetData, layerIndex, relativePixels, strokeStarted) ->
    # Override to process new pixels being added to the stroke.

  endStroke: (assetData) ->
    # Override to process the end of the stroke.
