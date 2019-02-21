LOI = LandsOfIllusions

LOI.Assets.Mesh.Object.Solver.Polyhedron.computeClusterPlanes = (clusters, cameraAngle) ->
  console.log "Computing cluster planes", clusters, cameraAngle if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug

  # See if we have a cluster overlapping the camera origin and set it as the base to calculate other clusters from.
  origin = cameraAngle.unprojectPoint new THREE.Vector3

  visitedClusters = []

  if originCluster = _.find(clusters, (cluster) => cluster.findPixelAtAbsoluteCoordinate origin.x, origin.y)
    originCluster.setPlanePoint new THREE.Vector3

    # Compute planes for the first time.
    propagateCluster originCluster, cameraAngle, visitedClusters, []

  # Set all free-floating clusters to go through the origin.
  for cluster in clusters when cluster not in visitedClusters
    # Assume the cluster is in the origin plane.
    cluster.setPlanePoint new THREE.Vector3
    propagateCluster cluster, cameraAngle, visitedClusters, []

propagateCluster = (cluster, cameraAngle, visitedClusters, nextClusters) ->
  visitedClusters.push cluster

  # Position all edges based on our plane.
  for otherClusterId, edge of cluster.edges
    otherCluster = edge.getOtherCluster cluster

    # Skip clusters that have already been determined.
    if otherCluster.plane.point
      # See if the edge needs to bo positioned.
      edge.caluclateLinePoint() unless edge.line.point
      continue

    # Project edge vertices onto cluster. Note that edge vertices are positioned
    # into the top-left corner of the pixel, so we use the -0.5 offset.
    vertices = cameraAngle.projectPoints edge.vertices, cluster.getPlane(), -0.5, -0.5

    # Edge point is the average of the projected vertices.
    edge.line.point = new THREE.Vector3
    edge.line.point.add vertex for vertex in vertices
    edge.line.point.multiplyScalar 1 / vertices.length

    # Anchor the other cluster to the edge point.
    otherCluster.setPlanePoint edge.line.point

  # Propagate to other clusters.
  for otherClusterId, edge of cluster.edges
    otherCluster = edge.getOtherCluster cluster

    continue if otherCluster in visitedClusters or otherCluster in nextClusters

    nextClusters.push otherCluster

  return unless nextCluster = nextClusters.shift()

  propagateCluster nextCluster, cameraAngle, visitedClusters, nextClusters
