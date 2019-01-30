AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

Bresenham = require('bresenham-zingl')

class LOI.Assets.SpriteEditor.Tools.Stroke extends LOI.Assets.SpriteEditor.Tools.Tool
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

    @pixels = new ReactiveField null

  onActivated: ->
    @processStroke()

    @_previewActive = false

    @_updatePreviewAutorun = @autorun (computation) =>
      # Show preview when we're drawing a line and mouse is on the canvas.
      preview = (@data.get('drawPreview') or @drawLine()) and @editor()?.mouse().pixelCoordinate()

      if preview
        # Update preview pixels.
        @editor().operationPreview().pixels @pixels()

      else if @_previewActive
        # Remove pixels, since we were the ones providing them.
        @editor().operationPreview().pixels []

      @_previewActive = preview

  createPixelsFromCoordinates: (coordinates) ->
    # Override to create full pixel data out of stroke coordinates.
    coordinates

  onDeactivated: ->
    @_updatePreviewAutorun.stop()
    @editor().operationPreview().pixels []

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
          @updatePixels()

    else if @drawLine()
      # React to any modifier changes when line drawing.
      @updatePixels()

  onKeyUp: (event) ->
    super arguments...

    if event.which is AC.Keys.shift
      @drawStraight false
      @drawLine false
      @updatePixels()

    else if @drawLine()
      # React to any modifier changes when line drawing.
      @updatePixels()

  onMouseDown: (event) ->
    super arguments...

    @_strokeStarted = true

    @processStroke()

  onMouseMove: (event) ->
    super arguments...

    @processStroke()

  processStroke: ->
    currentPixelCoordinates = @currentPixelCoordinates()

    if @mouseState.x? and @mouseState.y?
      newPixelCoordinates =
        x: @mouseState.x
        y: @mouseState.y

      if @drawStraight()
        _.extend newPixelCoordinates, @lockedCoordinate()

    # This is the start of the stroke if we don't have any previous coordinates.
    startOfStroke = not @lastStrokeCoordinates()

    # Update coordinates if they are new.
    unless EJSON.equals currentPixelCoordinates, newPixelCoordinates
      @currentPixelCoordinates newPixelCoordinates

    else
      # Coordinates are the same, so if we're in the middle of the stroke
      # we have already applied the tool here and there's nothing new to do.
      return unless startOfStroke

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

    if @drawLine()
      if keyboardState.isMetaDown()
        # Draw perfect pixel art line.
        pixelCoordinates = @perfectLine lastPixelCoordinates, currentPixelCoordinates

      else
        @perfectLineRatio null

        # Draw bresenham line from last coordinates (which persist after end of stroke).
        Bresenham.line lastPixelCoordinates.x, lastPixelCoordinates.y, currentPixelCoordinates.x, currentPixelCoordinates.y, (x, y) => pixelCoordinates.push {x, y}

    else
      # Apply locked coordinate.
      if @drawStraight()
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

    # TODO: Apply symmetry.
    # symmetryXOrigin = @options.editor().symmetryXOrigin?()
    #if symmetryXOrigin?
    #  mirroredX = -@mouseState.x + 2 * symmetryXOrigin
    #  xCoordinates.push [mirroredX, -1]

    @pixels @createPixelsFromCoordinates pixelCoordinates
    @applyTool()

  onMouseUp: (event) ->
    super arguments...

    # End stroke.
    @lastStrokeCoordinates null
    @secondToLastStrokeCoordinates null

    @drawStraight false

    @updatePixels()

  applyTool: ->
    return unless @mouseState.leftButton

    spriteData = @editor().spriteData()

    layerIndex = @paintHelper.layerIndex()
    layer = spriteData.layers?[layerIndex]

    layerOrigin =
      x: layer?.origin?.x or 0
      y: layer?.origin?.y or 0

    absolutePixels = @pixels()
    drawStraight = @drawStraight()
    currentPixelCoordinates = @currentPixelCoordinates()

    if drawStraight
      lastPixelCoordinates = @lastPixelCoordinates()

      unless lockedCoordinate = @lockedCoordinate()
        # Calculate which direction to lock to.
        if currentPixelCoordinates.x is lastPixelCoordinates.x
          # Lock to vertical straight lines.
          lockedCoordinate = x: lastPixelCoordinates.x

        else
          lockedCoordinate = y: lastPixelCoordinates.y

        @lockedCoordinate lockedCoordinate

    relativePixels = []

    for absolutePixel in absolutePixels
      # If we have fixed bounds, make sure we're inside.
      if spriteData.bounds?.fixed
        continue unless spriteData.bounds.left <= absolutePixel.x <= spriteData.bounds.right and spriteData.bounds.top <= absolutePixel.y <= spriteData.bounds.bottom

      relativePixel = _.clone absolutePixel
      _.extend relativePixel, lockedCoordinate if drawStraight

      # Pixel must be in relative coordinates.
      relativePixel.x -= layerOrigin.x
      relativePixel.y -= layerOrigin.y
        
      relativePixels.push relativePixel

    @applyPixels spriteData, layerIndex, relativePixels, @_strokeStarted

    # Save start of current stroke segment to allow smoothing.
    @secondToLastStrokeCoordinates @lastStrokeCoordinates()

    # Save last absolute pixel as the end of the stroke.
    @lastPixelCoordinates currentPixelCoordinates
    @lastStrokeCoordinates currentPixelCoordinates

    @_strokeStarted = false

  applyPixels: (spriteData, layerIndex, pixels, strokeStarted) ->
    # Override to call a method that will send the operation on the server.
