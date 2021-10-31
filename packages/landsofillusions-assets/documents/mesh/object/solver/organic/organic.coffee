AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver.Organic extends LOI.Assets.Mesh.Object.Solver
  @type = LOI.Assets.Mesh.Object.Solver.Types.Organic
  @debug = false

  constructor: ->
    super arguments...

    @clusters = {}
    @islandParts = []

    # Initialize clusters.
    for clusterId, clusterData of @object.clusters()
      @clusters[clusterId] = new @constructor.Cluster clusterData

  initialize: ->
    clustersArray = _.values @clusters

    # Determine cluster adjacency.
    cluster.findPictureNeighbors clustersArray for cluster in clustersArray

    # Determine island parts.
    cluster.initializeIslandPart @islandParts for cluster in clustersArray

    # Determine island part edges.
    islandPart.determineEdges @islandParts for islandPart in @islandParts

    # Determine islands.

    # Determine island origins.

    # Create pixel network.

    # Calculate depth.

    # Create vertices.

    # Create the mesh.


  update: (addedClusterIds, updatedClusterIds, removedClusterIds) ->
    clustersData = @object.clusters()
