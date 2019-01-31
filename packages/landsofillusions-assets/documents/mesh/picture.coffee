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
      bounds: _.pick @_bounds, ['x', 'y', 'width', 'height']
      maps: {}

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

  setPixels: (pixels) ->
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
      if pixel.x < @_bounds.left
        boundsUpdated = true
        @_bounds.left = pixel.x

      if pixel.x > @_bounds.right
        boundsUpdated = true
        @_bounds.right = pixel.x

      if pixel.y < @_bounds.top
        boundsUpdated = true
        @_bounds.top = pixel.y

      if pixel.y > @_bounds.bottom
        boundsUpdated = true
        @_bounds.bottom = pixel.y

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
      x = pixel.x - @_bounds.x
      y = pixel.y - @_bounds.y

      for mapType, value of pixel when mapType isnt 'x' and mapType isnt 'y'
        if value?
          map = @getMap mapType
          map.setPixel x, y, value
          flagsMap.setPixelFlag x, y, map.constructor.flagValue
          
        else
          # We only need to clear the pixel if we have the map.
          continue unless map = @maps[mapType]
          map.clearPixel x, y
          flagsMap.clearPixelFlag x, y, map.constructor.flagValue

    @contentUpdated()
    
  clearPixels: (pixels) ->
    # Clear pixels from maps.
    for type, map of @maps
      for pixel in pixels
        map.clearPixel pixel.x - @_bounds.x, pixel.y - @_bounds.y

    # Update bounds to account for removed pixels.
    recomputeBounds = false

    for pixel in pixels
      # Only if the pixel is on the edge we might need to recompute bounds.
      if pixel.x is @_bounds.left or pixel.x is @_bounds.right or pixel.y is @_bounds.top or pixel.y is @_bounds.bottom
        recomputeBounds = true

    if recomputeBounds
      # Analyze the flags map to see which pixels are present.
      @_bounds = @maps[@constructor.Map.Types.Flags].computeBounds()
      @_calculateBoundsParameters()
      @bounds.changedLocally()
      
      # Resize maps.
      for type, map of @maps
        map.resizeToPictureBounds()

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
