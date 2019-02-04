AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture
  constructor: (@pictures, @index, data) ->
    @layer = @pictures.parent

    @_updatedDependency = new Tracker.Dependency

    @cameraAngleIndex = data.cameraAngle

    @_bounds = data.bounds
    @maps = {}

    if @_bounds
      @_calculateBoundsEdges()

      for type, map of data.maps
        className = _.upperFirst type
        @maps[type] = new @constructor.Map[className] @, map.compressedData
        
    @bounds = new LOI.Assets.Mesh.ValueField @, 'bounds', @_bounds

  _calculateBoundsEdges: ->
    @_bounds.left = @_bounds.x
    @_bounds.top = @_bounds.y
    @_bounds.right = @_bounds.x + @_bounds.width - 1
    @_bounds.bottom = @_bounds.y + @_bounds.height - 1

  _calculateBoundsParameters: ->
    @_bounds.x = @_bounds.left
    @_bounds.y = @_bounds.top
    @_bounds.width = @_bounds.right - @_bounds.left + 1
    @_bounds.height = @_bounds.bottom - @_bounds.top + 1

  toPlainObject: ->
    plainObject =
      maps: {}
      
    if @_bounds
      plainObject.bounds = _.pick @_bounds, ['x', 'y', 'width', 'height']

    for type, map of @maps
      plainObject.maps[type] =
        compressedData: map.getCompressedData()

    plainObject

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatedDependency.changed()
    @pictures.contentUpdated()

  cameraAngle: ->
    @layer.object.mesh.cameraAngles.get @cameraAngleIndex

  setPixels: (pixels, relative) ->
    # Update bounds to accommodate all new pixels.
    boundsUpdated = false

    unless @_bounds
      # Create bounds around the first pixel.
      firstPixel = pixels[0]
      
      @_bounds = 
        x: firstPixel.x
        y: firstPixel.y
        width: 1
        height: 1

      @_calculateBoundsEdges()
      @bounds @_bounds

      boundsUpdated = true
      
    for pixel in pixels
      # We need to update bounds in absolute coordinates.
      absoluteX = pixel.x
      absoluteY = pixel.y

      if relative
        absoluteX += @_bounds.x
        absoluteY += @_bounds.y

      if absoluteX < @_bounds.left
        boundsUpdated = true
        @_bounds.left = absoluteX

      if absoluteX > @_bounds.right
        boundsUpdated = true
        @_bounds.right = absoluteX

      if absoluteY < @_bounds.top
        boundsUpdated = true
        @_bounds.top = absoluteY

      if absoluteY > @_bounds.bottom
        boundsUpdated = true
        @_bounds.bottom = absoluteY

    # Ensure we have the flags map before we resize bounds.
    flagsMap = @getMap @constructor.Map.Types.Flags

    if boundsUpdated
      # Calculate new bound parameters and inform others of change.
      @_calculateBoundsParameters()
      @bounds.changedLocally()

      # Resize maps.
      for type, map of @maps
        map.resizeToPictureBounds()

    # Transfer pixels to maps.      
    for pixel in pixels
      # We need to send pixels with relative coordinates.
      relativeX = pixel.x
      relativeY = pixel.y

      unless relative
        relativeX -= @_bounds.x
        relativeY -= @_bounds.y

      for mapType, value of pixel when mapType isnt 'x' and mapType isnt 'y'
        if value?
          map = @getMap mapType
          map.setPixel relativeX, relativeY, value
          flagsMap.setPixelFlag relativeX, relativeY, map.constructor.flagValue
          
        else
          # We only need to clear the pixel if we have the map.
          continue unless map = @maps[mapType]
          map.clearPixel relativeX, relativeY
          flagsMap.clearPixelFlag relativeX, relativeY, map.constructor.flagValue

    @contentUpdated()
    
  clearPixels: (pixels, relative) ->
    return unless @_bounds

    # Clear pixels from maps.
    for type, map of @maps
      for pixel in pixels
        # We need to send pixels with relative coordinates.
        relativeX = pixel.x
        relativeY = pixel.y

        unless relative
          relativeX -= @_bounds.x
          relativeY -= @_bounds.y

        continue unless 0 <= relativeX < map.width and 0 <= relativeY < map.height

        map.clearPixel relativeX, relativeY

    # Update bounds to account for removed pixels.
    recomputeBounds = false

    for pixel in pixels
      # We need to update bounds in absolute coordinates.
      absoluteX = pixel.x
      absoluteY = pixel.y

      if relative
        absoluteX += @_bounds.x
        absoluteY += @_bounds.y

      # Only if the pixel is on the edge we need to recompute bounds.
      if absoluteX is @_bounds.left or absoluteX is @_bounds.right or absoluteY is @_bounds.top or absoluteY is @_bounds.bottom
        recomputeBounds = true
        break

    if recomputeBounds
      # Analyze the flags map to see which pixels are present.
      newBounds = @maps.flags.computeBounds()
      boundsHaveChanged = false

      if newBounds? is @_bounds?
        for key, value of newBounds
          unless @_bounds[key] is value
            boundsHaveChanged = true
            break

      else
        boundsHaveChanged = true

      if boundsHaveChanged
        @_bounds = newBounds

        if @_bounds
          @_calculateBoundsEdges()

          @bounds @_bounds

          # Resize maps.
          for type, map of @maps
            map.resizeToPictureBounds()

        else
          # Delete all maps.
          @maps = {}

    @contentUpdated()
    
  getMap: (type) ->
    return @maps[type] if @maps[type]
    
    className = _.upperFirst type
    @maps[type] = new @constructor.Map[className] @

    @maps[type]

  getMapValuesForPixel: (x, y) ->
    @getMapValuesForPixelRelative x - @_bounds.x, y - @_bounds.y

  getMapValuesForPixelRelative: (x, y) ->
    flagsMap = @getMap @constructor.Map.Types.Flags

    return unless flags = flagsMap.getPixel x, y

    mapValues = {}

    for type, map of @maps when flags & map.constructor.flagValue
      mapValues[type] = map.getPixel x, y

    mapValues
    
  pixelExists: (x, y) ->
    @pixelExistsRelative x - @_bounds.x, y - @_bounds.y

  pixelExistsRelative: (x, y) ->
    flagsMap = @getMap @constructor.Map.Types.Flags

    flagsMap.pixelExists x, y
