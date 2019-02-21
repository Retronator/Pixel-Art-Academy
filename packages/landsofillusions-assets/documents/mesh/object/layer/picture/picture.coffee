LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Layer.Picture
  @debug = false

  constructor: (@pictures, @index, data) ->
    @layer = @pictures.parent

    @_updatedDependency = new Tracker.Dependency

    @cameraAngleIndex = data.cameraAngle

    @_bounds = data.bounds
    @maps = {}
    @clusters = {}

    if @_bounds
      @_calculateBoundsEdges()

      # Create all maps.
      for type, map of data.maps
        className = _.upperFirst type
        @maps[type] = new @constructor.Map[className] @, map.compressedData

      for id, cluster of data.clusters
        @clusters[id] = new @constructor.Cluster @, id, cluster

    @bounds = new LOI.Assets.Mesh.ValueField @, 'bounds', @_bounds

    # Recompute clusters for the first time if we didn't get them.
    @_recomputeClusters [], [] unless data.clusters and data.maps?.clusterId

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
    
  _resizeMaps: ->
    for type, map of @maps
      map.resizeToPictureBounds()

  _removeMaps: ->
    @maps = {}

  toPlainObject: ->
    plainObject =
      maps: {}
      clusters: {}
      
    if @_bounds
      plainObject.bounds = _.pick @_bounds, ['x', 'y', 'width', 'height']

    for type, map of @maps
      plainObject.maps[type] =
        compressedData: map.getCompressedData()
        
    for clusterId, cluster of @clusters
      plainObject.clusters[clusterId] = cluster.toPlainObject()

    plainObject

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatedDependency.changed()
    @pictures.contentUpdated()

  cameraAngle: ->
    @layer.object.mesh.cameraAngles.get @cameraAngleIndex

  getAbsoluteCoordinates: (relativeCoordinates) ->
    x: relativeCoordinates.x + @_bounds.x
    y: relativeCoordinates.y + @_bounds.y

  getRelativeCoordinates: (absoluteCoordinates) ->
    x: absoluteCoordinates.x - @_bounds.x
    y: absoluteCoordinates.y - @_bounds.y

  getMap: (type) ->
    # The rest of the maps are in the maps array.
    return @maps[type] if @maps[type]

    className = _.upperFirst type
    @maps[type] = new @constructor.Map[className] @

    @maps[type]

  getMapValuesForPixel: (x, y) ->
    @getMapValuesForPixelRelative x - @_bounds.x, y - @_bounds.y

  getMapValuesForPixelRelative: (x, y) ->
    return unless flagsMap = @maps[@constructor.Map.Types.Flags]
    return unless flags = flagsMap.getPixel x, y

    mapValues = {}

    for type, map of @maps when flags & map.constructor.flagValue
      mapValues[type] = map.getPixel x, y

    mapValues
    
  pixelExists: (x, y) ->
    @pixelExistsRelative x - @_bounds.x, y - @_bounds.y

  pixelExistsRelative: (x, y) ->
    # Make sure the pixel is inside bounds.
    return unless 0 <= x < @_bounds.width and 0 <= y < @_bounds.height
    
    return unless flagsMap = @maps[@constructor.Map.Types.Flags]

    flagsMap.pixelExists x, y
