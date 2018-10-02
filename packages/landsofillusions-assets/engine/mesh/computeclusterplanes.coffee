LOI = LandsOfIllusions

LOI.Assets.Engine.Mesh.computeClusterPlanes = (clusters, cameraAngle) ->
  console.log "Computing cluster planes", clusters, cameraAngle if LOI.Assets.Engine.Mesh.debug

  # Place the plane of the cluster under the Origin landmark to the coordinate system origin.
  origin = _.find cameraAngle.sprite.landmarks, (landmark) => landmark.name is 'Origin'

  # If no Origin landmark is found, use the world origin.
  origin ?= cameraAngle.unprojectPoint new THREE.Vector3

  if originCluster = _.find(clusters, (cluster) => cluster.findPixelAtCoordinate origin.x, origin.y)
    originCluster.plane.point = new THREE.Vector3

    # Compute planes for the first time.
    propagateCluster originCluster, cameraAngle, [], []

  # Set all free-floating clusters to go through the origin.
  for cluster in clusters when not cluster.plane.point
    # Assume the cluster is in the origin plane.
    cluster.plane.point = new THREE.Vector3
    propagateCluster cluster, cameraAngle, [], []

propagateCluster = (cluster, cameraAngle, visitedClusters, nextClusters) ->
  visitedClusters.push cluster

  # Position all edges based on our plane.
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
    edge.line.point = new THREE.Vector3
    edge.line.point.add vertex for vertex in vertices
    edge.line.point.multiplyScalar 1 / vertices.length

    # Anchor the other cluster to the edge point.
    otherCluster.plane.point = edge.line.point

  # Propagate to other clusters.
  for edge in cluster.edges
    otherCluster = if edge.clusterA is cluster then edge.clusterB else edge.clusterA

    continue if otherCluster in visitedClusters or otherCluster in nextClusters

    nextClusters.push otherCluster

  return unless nextCluster = nextClusters.shift()

  propagateCluster nextCluster, cameraAngle, visitedClusters, nextClusters
