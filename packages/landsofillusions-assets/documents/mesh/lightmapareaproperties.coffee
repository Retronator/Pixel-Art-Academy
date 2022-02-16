AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.LightmapAreaProperties
  @maxlightmapSize: 4096

  constructor: (@mesh) ->
    @areaProperties = []

    # Index map stores indices by object index, layer index, and cluster ID.
    @indicesMap = []

    @_updatedDependency = new Tracker.Dependency

    @texture = new LOI.Engine.Textures.LightmapAreaProperties
    @lightmapSize = new ReactiveField width: 0, height: 0

    # Update area properties. We need to do it in an autorun to depend on area changes.
    Tracker.nonreactive =>
      @_updateAutorun = Tracker.autorun =>
        @update()

    # Update texture when lightmap area or lightmap values change.
    Tracker.nonreactive =>
      @_updateTextureAutorun = Tracker.autorun =>
        return unless lightmap = @mesh.lightmap()
        @_updatedDependency.depend()

        @texture.update @areaProperties, lightmap

  destroy: ->
    @_updateAutorun.stop()
    @_updateTextureAutorun.stop()

  update: ->
    # Get all the areas.
    areas = []

    for object in @mesh.objects.getAllWithoutUpdates()
      layers = object.layers.getAllWithoutUpdates()
      lightmapAreaType = object.solver.constructor.lightmapAreaType()

      for layer in layers
        if picture = layer.pictures.get 0
          if picture.bounds()
            switch lightmapAreaType
              when LOI.Assets.Mesh.Object.Solver.LightmapAreaTypes.Layer
                areas.push layer

              when LOI.Assets.Mesh.Object.Solver.LightmapAreaTypes.Cluster
                areas.push cluster for clusterId, cluster of layer.clusters.getAllWithoutUpdates()

    # Extract area properties.
    @areaProperties = []

    for area in areas
      # Determine the size of the area.
      if area instanceof LOI.Assets.Mesh.Object.Layer
        picture = area.pictures.get 0
        bounds = picture.bounds()
        properties =
          layerIndex: area.index
          objectIndex: area.object.index

      else if area instanceof LOI.Assets.Mesh.Object.Layer.Cluster
        bounds = area.boundsInPicture()
        properties =
          clusterId: area.id
          layerIndex: area.layer.index
          objectIndex: area.layer.object.index

      # Find out which level (power of 2 size) we'll need for this area.
      maxSize = Math.max bounds.width, bounds.height
      properties.level = Math.ceil Math.log2 maxSize
      properties.size = 2 ** properties.level

      @areaProperties.push properties

    # Sort by size for better lightmap packing.
    @areaProperties.sort (a, b) => b.size - a.size

    # Calculate positions in the lightmap.
    lightmapWidth = @areaProperties[0]?.size or 0
    lightmapHeight = 0
    currentColumnLeft = 0
    currentRowBottom = @areaProperties[0]?.size or 0
    currentLeft = 0
    currentTop = 0

    for area, areaIndex in @areaProperties
      # Move down if we can't fit in the current row any more.
      if currentLeft + area.size > lightmapWidth
        currentTop = currentRowBottom
        currentRowBottom += area.size
        currentLeft = currentColumnLeft

      # If the area can't fit in the current column, start a new column.
      if currentTop + area.size > @constructor.maxlightmapSize
        currentColumnLeft = lightmapWidth
        currentLeft = currentColumnLeft
        currentTop = 0
        lightmapWidth += area.size
        currentRowBottom = area.size

      area.positionX = currentLeft
      area.positionY = currentTop

      # Move right.
      currentLeft += area.size

      # Update max height.
      lightmapHeight = Math.max lightmapHeight, currentRowBottom

    # Update how big the lightmap needs to be.
    @lightmapSize
      width: _.ceilToPower lightmapWidth, 2
      height: _.ceilToPower lightmapHeight, 2

    # Index for querying by area.
    @indexMap = []

    for entry, index in @areaProperties
      @indicesMap[entry.objectIndex] ?= []

      if entry.clusterId
        @indicesMap[entry.objectIndex][entry.layerIndex] ?= []
        @indicesMap[entry.objectIndex][entry.layerIndex][entry.clusterId] = index

      else
        @indicesMap[entry.objectIndex][entry.layerIndex] = index

    @_updatedDependency.changed()

  getIndex: (area) ->
    @_updatedDependency.depend()

    if area instanceof LOI.Assets.Mesh.Object.Layer
      @indicesMap[area.object.index]?[area.index]

    else if area instanceof LOI.Assets.Mesh.Object.Layer.Cluster
      @indicesMap[area.layer.object.index]?[area.layer.index]?[area.id]

  getPropertiesForArea: (area) ->
    @areaProperties[@getIndex area]

  getAll: ->
    @_updatedDependency.depend()
    @areaProperties
