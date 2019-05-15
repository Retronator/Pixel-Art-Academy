LOI = LandsOfIllusions

LOI.Assets.Mesh.Object.Solver.Polyhedron.computeClusterPlanes = (clusters, edges, cameraAngle) ->
  console.log "Computing cluster planes", clusters, edges, cameraAngle if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

  # Reset all cluster plane and edge points.
  cluster.plane.point = null for cluster in clusters
  edge.line.point = null for edge in edges

  clustersLeftCount = clusters.length

  # See if we have a cluster overlapping the camera target and set it as the base to calculate other clusters from.
  origin = cameraAngle.unprojectPoint cameraAngle.target

  if originCluster = _.find(clusters, (cluster) => cluster.findPixelAtAbsoluteCoordinate origin.x, origin.y)
    originCluster.setPlanePoint new THREE.Vector3
    clustersLeftCount--

  sortedEdges = _.reverse _.sortBy edges, (edge) => edge.segments.length

  while clustersLeftCount
    positionedCluster = true

    while positionedCluster
      positionedCluster = false

      for edge in sortedEdges when not edge.line.point
        if edge.clusterA.plane.point and edge.clusterB.plane.point
          # Both clusters have been positioned, we only need to place this edge.
          edge.calculateLinePoint()
          continue

        else if not (edge.clusterA.plane.point or edge.clusterB.plane.point)
          # None of the clusters have been positioned so we can't do anything with this edge yet.
          continue

        else
          # We can position one of the clusters.
          if edge.clusterA.plane.point
            # Cluster B needs to be positioned based on cluster A.
            sourceCluster = edge.clusterA
            targetCluster = edge.clusterB

          else
            # Cluster A needs to be positioned based on cluster B.
            sourceCluster = edge.clusterB
            targetCluster = edge.clusterA

          # Project edge vertices onto cluster. Note that edge vertices are positioned
          # into the top-left corner of the pixel, so we use the -0.5 offset.
          vertices = cameraAngle.projectPoints edge.vertices, sourceCluster.getPlane(), -0.5, -0.5

          # Edge point is the average of the projected vertices.
          edge.line.point = new THREE.Vector3
          edge.line.point.add vertex for vertex in vertices
          edge.line.point.multiplyScalar 1 / vertices.length

          # Anchor the other cluster to the edge point.
          targetCluster.setPlanePoint edge.line.point

          positionedCluster = true
          clustersLeftCount--
          break

    # We've positioned all the clusters we could. See if there are any clusters left not positioned.
    if clustersLeftCount
      # Place the first not positioned cluster to origin.
      for cluster in clusters when not cluster.plane.point
        cluster.setPlanePoint new THREE.Vector3
        clustersLeftCount--
        break

  # All clusters have been positioned. Make sure all edges are positioned too.
  edge.calculateLinePoint() for edge in edges when not edge.line.point
