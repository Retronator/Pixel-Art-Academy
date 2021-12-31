AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver.Polyhedron extends LOI.Assets.Mesh.Object.Solver
  @type = LOI.Assets.Mesh.Object.Solver.Types.Polyhedron
  @debug = false

  @lightmapAreaType: -> LOI.Assets.Mesh.Object.Solver.LightmapAreaTypes.Cluster

  constructor: ->
    super arguments...
    
    @clusters = {}
    @edges = []
    
    # Initialize clusters.
    for clusterId, clusterData of @object.clusters()
      @clusters[clusterId] = new @constructor.Cluster clusterData
      
  initialize: ->
    clustersArray = _.values @clusters

    console.log "Initialize solver with clusters", @clusters if @constructor.debug

    # Update pixels in all clusters.
    cluster.updatePixels() for cluster in clustersArray

    # Compute edges.
    @edges = @computeEdges clustersArray

    # Recompute cluster planes.
    cameraAngle = @object.mesh.cameraAngles.get 0
    @computeClusterPlanes clustersArray, @edges, cameraAngle

    # Recompute clusters.
    @projectClusterPoints clustersArray, cameraAngle
    @computeClusterMeshes clustersArray

  update: (addedClusterIds, updatedClusterIds, removedClusterIds) ->
    clustersData = @object.clusters()
      
    # Add added clusters to topology.
    for addedClusterId in addedClusterIds
      # Note: Recomputation of pixels and edges is automatically set to true when cluster is constructed.
      @clusters[addedClusterId] = new @constructor.Cluster clustersData[addedClusterId]
      
    # Mark updated clusters for recomputation.
    for updatedClusterId in updatedClusterIds
      cluster = @clusters[updatedClusterId]
      cluster.recomputePixels = true
      cluster.recomputeEdges = true

    # Remove removed clusters from topology.
    for removedClusterId in removedClusterIds
      # Remove all edges so they also get removed from neighbors.
      cluster = @clusters[removedClusterId]
      for otherClusterId, edge of cluster.edges
        edge.removeFromClusters()

        # The neighbor must recompute edges.
        neighbor = edge.getOtherCluster cluster
        neighbor.recomputeEdges = true

      delete @clusters[removedClusterId]

    console.log "Solving polyhedron clusters", @clusters, addedClusterIds, updatedClusterIds, removedClusterIds if @constructor.debug
      
    # Notify start of recomputation, so that clusters can track changes in this update.
    for clusterId, cluster of @clusters
      cluster.startRecomputation()

    clustersArray = _.values @clusters
    recomputePixelsClusters = _.filter clustersArray, (cluster) => cluster.recomputePixels

    # Update pixels in clusters that need recomputation.
    cluster.updatePixels() for cluster in recomputePixelsClusters

    console.log "Recomputed pixels in clusters", recomputePixelsClusters if @constructor.debug

    # Compute edges.
    @edges = @computeEdges clustersArray

    # Recompute cluster planes.
    cameraAngle = @object.mesh.cameraAngles.get 0
    @computeClusterPlanes clustersArray, @edges, cameraAngle
    
    # Recompute clusters that have have changed.
    changedClusters = (cluster for cluster in clustersArray when cluster.changed())

    @projectClusterPoints changedClusters, cameraAngle
    @computeClusterMeshes changedClusters

    # Generate geometries and send them to layer clusters.
    for cluster in changedClusters
      clusterData = clustersData[cluster.id]
      clusterData.boundsInPicture cluster.boundsInPicture
      clusterData.geometry cluster.generateGeometry()
      clusterData.plane
        point: cluster.plane.point.toObject()
        normal: cluster.plane.normal.toObject()

    console.log "Generated geometry for clusters", changedClusters if @constructor.debug
