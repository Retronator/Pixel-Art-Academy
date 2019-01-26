AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

bresenhamLine = require('bresenham-zingl').line

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
    @lockedCoordinate = new ReactiveField null

    @perfectLineRatio = new ReactiveField null

    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint

  destroy: ->
    @pixelCoordinates?.stop()
    @pixels?.stop()

  onActivated: ->
    @currentPixelCoordinates
      x: @mouseState.x
      y: @mouseState.y

    # Calculate which pixels the tool would fill.
    @pixelCoordinates = new ComputedField =>
      return [] unless currentPixelCoordinates = @currentPixelCoordinates()
      lastPixelCoordinates = @lastPixelCoordinates() or currentPixelCoordinates
      lastStrokeCoordinates = @lastStrokeCoordinates() or currentPixelCoordinates

      keyboardState = AC.Keyboard.getState()
      pixels = []

      if @drawLine()
        if keyboardState.isMetaDown()
          # Draw perfect pixel art line.
          pixels = @perfectLine lastPixelCoordinates, currentPixelCoordinates

        else
          @perfectLineRatio null

          # Draw bresenham line from last coordinates (persist after end of stroke).
          bresenhamLine lastPixelCoordinates.x, lastPixelCoordinates.y, currentPixelCoordinates.x, currentPixelCoordinates.y, (x, y) => pixels.push {x, y}

      else
        # Apply locked coordinate.
        if @drawStraight()
          currentPixelCoordinates = _.extend {}, currentPixelCoordinates, @lockedCoordinate()

        # Draw bresenham line from last stroke coordinates (reset after end of stroke).
        bresenhamLine lastStrokeCoordinates.x, lastStrokeCoordinates.y, currentPixelCoordinates.x, currentPixelCoordinates.y, (x, y) => pixels.push {x, y}

      # TODO: Apply symmetry.
      # symmetryXOrigin = @options.editor().symmetryXOrigin?()
      #if symmetryXOrigin?
      #  mirroredX = -@mouseState.x + 2 * symmetryXOrigin
      #  xCoordinates.push [mirroredX, -1]

      pixels
    ,
      true

    @pixels = new ComputedField =>
      @createPixelsFromCoordinates @pixelCoordinates()
    ,
      true

    @_previewActive = false

    @_updatePreviewAutorun = @autorun (computation) =>
      # Show preview when we're drawing a line and mouse is on the canvas.
      preview = @isActive() and (@data.get('drawPreview') or @drawLine()) and @editor()?.mouse().pixelCoordinate()

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
    @pixelCoordinates.stop()
    @pixels.stop()
    @_updatePreviewAutorun.stop()

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
      if @mouseState.leftButton
        @lockedCoordinate null
        @drawStraight true
        
      else
        @drawLine true

  onKeyUp: (event) ->
    super arguments...

    if event.which is AC.Keys.shift
      @drawStraight false
      @drawLine false

  onMouseDown: (event) ->
    super arguments...

    @applyTool()

  onMouseMove: (event) ->
    super arguments...

    currentPixelCoordinates = @currentPixelCoordinates()

    newPixelCoordinates =
      x: @mouseState.x
      y: @mouseState.y

    return if EJSON.equals currentPixelCoordinates, newPixelCoordinates

    @currentPixelCoordinates newPixelCoordinates

    @applyTool()

  onMouseUp: (event) ->
    super arguments...

    # End stroke.
    @lastStrokeCoordinates null

    @drawStraight false

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

    if drawStraight
      lastPixelCoordinates = @lastPixelCoordinates()
      lastNewPixel = _.last absolutePixels

      unless lockedCoordinate = @lockedCoordinate()
        # Calculate which direction to lock to.
        if lastNewPixel.x is lastPixelCoordinates.x
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

      absoluteCoordinates = _.pick absolutePixel, ['x', 'y']
      @lastPixelCoordinates absoluteCoordinates
      @lastStrokeCoordinates absoluteCoordinates
      
      relativePixel = _.clone absolutePixel
      _.extend relativePixel, lockedCoordinate if drawStraight

      # Pixel must be in relative coordinates.
      relativePixel.x -= layerOrigin.x
      relativePixel.y -= layerOrigin.y
        
      relativePixels.push relativePixel

    @processPixelsOnServer spriteData, layerIndex, relativePixels

  processPixelsOnServer: (spriteData, layerIndex, pixels) ->
    # Override to call a method that will send the operation on the server.
