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
