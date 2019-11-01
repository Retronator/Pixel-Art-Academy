AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object
  constructor: (@objects, @index, data) ->
    @mesh = @objects.parent

    @_updatedDependency = new Tracker.Dependency
    
    for field in ['name', 'visible']
      @[field] = new LOI.Assets.Mesh.ValueField @, field, data[field]

    # Set last cluster ID before we initialize layers, since pictures might create new clusters.
    @lastClusterId = data.lastClusterId or 0

    @layers = new LOI.Assets.Mesh.ArrayField @, 'layers', data.layers, @constructor.Layer

    # Create a map of clusters.
    @clusters = new ComputedField =>
      clusters = {}
      
      for layer in @layers.getAllWithoutUpdates()
        for clusterId, cluster of layer.clusters.getAllWithoutUpdates()
          clusters[clusterId] = cluster
        
      clusters

    # Create the solver.
    solverClassName = _.upperFirst data.solver or @constructor.Solver.Types.Polyhedron
    @solver = new @constructor.Solver[solverClassName] @

    # Run solver for the first time if we don't have clusters yet.
    clustersExist = false

    if data.layers
      for layer in data.layers when layer?.clusters
        clustersExist = true
        break

    @solver.update [], [], [] unless clustersExist

  toPlainObject: ->
    plainObject =
      lastClusterId: @lastClusterId
      solver: @solver.constructor.type

    @[field].save plainObject for field in ['name', 'visible', 'layers']

    plainObject

  depend: ->
    @_updatedDependency.depend()

  contentUpdated: ->
    @_updatedDependency.changed()
    @objects.contentUpdated()

  generateNewClusterId: ->
    # Increment and return a new cluster ID.
    ++@lastClusterId

  setSolver: (solverClassName) ->
    @solver = new @constructor.Solver[solverClassName] @
    
  recompute: ->
    previousLayerClusters = []

    # Clear all layer clusters, but store their data.
    for layer in @layers.getAll()
      previousLayerClusters.push layer.clusters.getAll()
      layer.clusters.clear()

    # Create a fresh solver.
    @solver = new @solver.constructor @

    # Recompute all clusters.
    @lastClusterId = 0
    previousPictureClusters = []

    for layer in @layers.getAll()
      layerClusters = []
      for picture in layer.pictures.getAll()
        # Save cluster info so we can map to them later.
        layerClusters.push picture.clusters

        picture.recomputeClusters()

      previousPictureClusters.push layerClusters

    # Match previous clusters to the new ones. Also accumulate the clusters with properties.
    clustersWithChangedProperties = []

    for layer, layerIndex in @layers.getAll()
      for picture, pictureIndex in layer.pictures.getAll()
        for previousClusterId, previousPictureCluster of previousPictureClusters[layerIndex][pictureIndex]
          # See if we have properties for this cluster.
          previousCluster = previousLayerClusters[layerIndex][previousClusterId]
          continue unless properties = previousCluster.properties()

          # See which cluster ID is now at the cluster's source coordinates.
          newClusterId = picture.getClusterIdForPixel previousPictureCluster.sourceCoordinates.x, previousPictureCluster.sourceCoordinates.y
          newCluster = layer.clusters.get newClusterId

          # Transfer properties to the new cluster.
          newCluster.properties properties

          # Mark that we've changed properties to this cluster.
          clustersWithChangedProperties.push newCluster.id

    # Trigger solver update to recompute cluster based on new properties.
    @solver.update [], clustersWithChangedProperties, []

  getSpriteBoundsAndLayersForCameraAngle: (cameraAngleIndex) ->
    bounds = null
    layers = []

    for layer in @layers.getAll()
      picture = layer.getPictureForCameraAngleIndex cameraAngleIndex
      continue unless pictureBounds = picture.bounds()

      pictureBoundsRectangle = AE.Rectangle.fromDimensions pictureBounds

      if bounds
        bounds = bounds.union pictureBoundsRectangle

      else
        bounds = pictureBoundsRectangle

      # Generate layer pixels.
      spriteLayer =
        pixels: picture.getSpritePixels()

      layers.push spriteLayer

    bounds = bounds?.toObject()

    {bounds, layers}
