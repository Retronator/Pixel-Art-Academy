AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver.Polyhedron.ClusterPlane
  constructor: (@initialCluster) ->
    @clusters = {}
    @clustersCount = 0

    @edges = {}

    @plane =
      point: null
      normal: @initialCluster.plane.normal

    @_addCluster @initialCluster

  _addCluster: (cluster) ->
    # See if we've already added this cluster.
    return if @clusters[cluster.id]

    # Add cluster.
    @clusters[cluster.id] = cluster
    cluster._clusterPlane = @
    @clustersCount++

    # Add all cluster edges.
    for otherClusterId, edge of cluster.edges
      otherCluster = edge.getOtherCluster cluster

      # See if the clusters are coplanar.
      coplanarClusters = false

      # The edges must be parallel to be coplanar.
      if edge.parallelClusters
        # Coplanar clusters need to come from the same layer, under the assumption that we're using
        # different layers so that clusters can overlap (since overlapping clusters can't be coplanar).
        # TODO: To support non-overlapping coplanar clusters on multiple layers, a full check should instead be performed, whether the overlap is happening.
        if edge.clusterA.layerCluster.layer is edge.clusterB.layerCluster.layer
          # The edge must also be longer than the longest edge between non-parallel clusters for at least one of the
          # clusters. This means that the parallel edge is more significant than others and we will use it to stick the
          # two clusters into the same plane.
          edgeLength = edge.segments.length
          thisLongestEdge = cluster.getLongestEdgeLengthBetweenNonParallelClusters()
          otherLongestEdge = otherCluster.getLongestEdgeLengthBetweenNonParallelClusters()

          coplanarClusters = true if edgeLength > thisLongestEdge or edgeLength > otherLongestEdge

      if coplanarClusters
        # Make sure the other cluster doesn't already belong to another cluster plane.
        if otherCluster._clusterPlane
          # If the other plane is this plane, that's OK, otherwise we'd be trying to assign the same cluster to two planes.
          unless otherCluster._clusterPlane is @
            throw new AE.InvalidOperationException "Tried to assign a cluster to two cluster planes.", otherCluster, @

        @_addCluster otherCluster

      else
        # This is an edge to another plane so we need to add it as an edge of the plane.
        @edges[otherClusterId] = otherCluster

  setPlanePoint: (point) ->
    @plane.point = THREE.Vector3.fromObject point

  getPlane: ->
    return unless @plane.point

    new THREE.Plane().setFromNormalAndCoplanarPoint @plane.normal, @plane.point

  applyToClusters: ->
    for clusterId, cluster of @clusters
      cluster.setPlanePoint @plane.point
