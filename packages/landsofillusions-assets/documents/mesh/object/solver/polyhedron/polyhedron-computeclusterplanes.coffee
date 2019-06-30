LOI = LandsOfIllusions

LOI.Assets.Mesh.Object.Solver.Polyhedron.computeClusterPlanes = (clusters, edges, cameraAngle) ->
  console.log "Computing cluster planes", clusters, edges, cameraAngle if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

  # Reset all cluster plane and edge points.
  clustersLeftCount = clusters.length

  for cluster in clusters
    if coplanarPoint = cluster.layerCluster.properties()?.coplanarPoint
      # Note: coplanar point does not have to have all coordinates defined.
      planePoint = new THREE.Vector3()
      planePoint[coordinate] = value for coordinate, value of coplanarPoint when value?
      console.log "Setting cluster #{cluster.id} to coplanar point.", planePoint if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
      cluster.setPlanePoint planePoint
      clustersLeftCount--

    else
      cluster.plane.point = null

  edge.line.point = null for edge in edges

  # See if we have a cluster overlapping the camera target.
  origin = cameraAngle.unprojectPoint cameraAngle.target
  originCluster = _.find clusters, (cluster) => cluster.findPixelAtAbsoluteCoordinate origin.x, origin.y

  # Otherwise look if a cluster is at the (0, 0) pixel.
  originCluster ?= _.find clusters, (cluster) => cluster.findPixelAtAbsoluteCoordinate 0, 0

  if originCluster and not originCluster.plane.point
    # Use the origin cluster as the base to calculate other clusters from.
    console.log "Setting cluster #{originCluster.id} to origin." if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
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
          console.log "Clusters #{edge.clusterA.id} and #{edge.clusterB.id} positioned. Place edge.", edge if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
          continue

        else if not (edge.clusterA.plane.point or edge.clusterB.plane.point)
          # None of the clusters have been positioned so we can't do anything with this edge yet.
          console.log "Clusters #{edge.clusterA.id} and #{edge.clusterB.id} not positioned. Continue." if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
          continue

        else
          # We can position one of the clusters.
          if edge.clusterA.plane.point
            # Cluster B needs to be positioned based on cluster A.
            console.log "Cluster #{edge.clusterB.id} positioned from #{edge.clusterA.id}." if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
            sourceCluster = edge.clusterA
            targetCluster = edge.clusterB

          else
            # Cluster A needs to be positioned based on cluster B.
            console.log "Cluster #{edge.clusterA.id} positioned from #{edge.clusterB.id}." if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
            sourceCluster = edge.clusterB
            targetCluster = edge.clusterA

          # Project edge vertices onto cluster. Note that edge vertices are positioned
          # into the top-left corner of the pixel, so we use the -0.5 offset.
          vertices = cameraAngle.projectPoints edge.vertices, sourceCluster.getPlane(), -0.5, -0.5

          console.warn "Edge vertices not projected successfully.", cameraAngle, edge.vertices, sourceCluster.getPlane() unless vertices.length

          # Edge point is the average of the projected vertices.
          edge.line.point = new THREE.Vector3
          edge.line.point.add vertex for vertex in vertices
          edge.line.point.multiplyScalar 1 / vertices.length

          # Anchor the other cluster to the edge point.
          targetCluster.setPlanePoint edge.line.point

          console.log "Cluster #{targetCluster.id} point is", edge.line.point, edge, vertices if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

          positionedCluster = true
          clustersLeftCount--
          break

    # We've positioned all the clusters we could. See if there are any clusters left not positioned.
    if clustersLeftCount
      # Place the first not positioned cluster to origin.
      for cluster in clusters when not cluster.plane.point
        console.log "Setting cluster #{cluster.id} to origin." if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
        cluster.setPlanePoint new THREE.Vector3
        clustersLeftCount--
        break

  # All clusters have been positioned. Make sure all edges are positioned too.
  edge.calculateLinePoint() for edge in edges when not edge.line.point
