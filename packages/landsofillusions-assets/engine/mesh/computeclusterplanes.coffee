LOI = LandsOfIllusions

LOI.Assets.Engine.Mesh.computeClusterPlanes = (originCluster, cameraAngle) ->
  console.log "Computing cluster planes", originCluster, cameraAngle if LOI.Assets.Engine.Mesh.debug

  propagateCluster originCluster, cameraAngle, []

propagateCluster = (cluster, cameraAngle, visitedClusters) ->
  visitedClusters.push cluster

  for edge in cluster.edges
    otherCluster = if edge.clusterA is cluster then edge.clusterB else edge.clusterA

    # Skip clusters that have already been determined.
    if otherCluster.plane.point
      # See if the edge needs to bo positioned.
      edge.caluclateLinePoint() unless edge.line.point
      continue

    # Project edge vertices onto cluster. Note that edge vertices are positioned 
    # into the top-left corner of the pixel, so we use the -0.5 offset.
    vertices = cameraAngle.projectPoints edge.vertices, cluster.getPlane(), -0.5, -0.5

    # Edge point is the average of the projected vertices.
    # TODO: Investigate other ways to fit the line to vertices.
    edge.line.point = new THREE.Vector3
    edge.line.point.add vertex for vertex in vertices
    edge.line.point.multiplyScalar 1 / vertices.length

    # Anchor both the other cluster to the edge point.
    otherCluster.plane.point = edge.line.point

  # Propagate to other clusters.
  for edge in cluster.edges
    otherCluster = if edge.clusterA is cluster then edge.clusterB else edge.clusterA

    return if otherCluster in visitedClusters

    propagateCluster otherCluster, cameraAngle, visitedClusters
