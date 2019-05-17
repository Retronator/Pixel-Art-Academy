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
    # Clear all layer clusters.
    for layer in @layers.getAll()
      layer.clusters.clear()

    # Create a fresh solver.
    @solver = new @solver.constructor @

    # Recompute all clusters.
    @lastClusterId = 0

    for layer in @layers.getAll()
      for picture in layer.pictures.getAll()
        picture.recomputeClusters()

  getSpriteBoundsAndLayersForCameraAngle: (cameraAngleIndex) ->
    bounds = null
    layers = []

    for layer in @layers.getAll()
      picture = layer.getPictureForCameraAngleIndex cameraAngleIndex
      continue unless bounds = picture.bounds()

      boundsRectangle = AE.Rectangle.fromDimensions bounds

      if bounds
        bounds = bounds.union boundsRectangle

      else
        bounds = boundsRectangle

      # Generate layer pixels.
      spriteLayer =
        pixels: picture.getSpritePixels()

      layers.push spriteLayer

    bounds = bounds?.toObject()

    {bounds, layers}
