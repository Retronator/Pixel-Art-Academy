AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver.Organic extends LOI.Assets.Mesh.Object.Solver
  @type = LOI.Assets.Mesh.Object.Solver.Types.Organic
  @debug = false

  @lightmapAreaType: -> LOI.Assets.Mesh.Object.Solver.LightmapAreaTypes.Layer

  constructor: ->
    super arguments...

    @clusters = {}
    @islands = []

    # Initialize clusters.
    for clusterId, clusterData of @object.clusters()
      @clusters[clusterId] = new @constructor.Cluster clusterData

  initialize: ->
    clustersArray = _.values @clusters

    # Determine cluster adjacency.
    cluster.findNeighbors clustersArray for cluster in clustersArray

    # Initialize islands.
    cluster.initializeIsland @islands for cluster in clustersArray

    # Determine island origins.
    island.determineOriginPixel() for island in @islands

    # Calculate depth.
    @depthCalculationIteration = 1
    cluster.updatePixelNormals() for cluster in clustersArray
    island.calculateDepth @depthCalculationIteration for island in @islands

    # Create vertices.

    # Create the mesh.


  update: (addedClusterIds, updatedClusterIds, removedClusterIds) ->
    clustersData = @object.clusters()
