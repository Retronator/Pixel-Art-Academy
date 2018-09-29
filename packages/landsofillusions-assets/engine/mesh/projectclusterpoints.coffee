LOI = LandsOfIllusions

LOI.Assets.Engine.Mesh.projectClusterPoints = (clusters, cameraAngle) ->
  console.log "Projecting cluster points", clusters, cameraAngle if LOI.Assets.Engine.Mesh.debug
  
  pixelDirections = [
    property: 'up', vector: new THREE.Vector2 0, -1
  ,
    property: 'down', vector: new THREE.Vector2 0, 1
  ,
    property: 'left', vector: new THREE.Vector2 -1, 0
  ,
    property: 'right', vector: new THREE.Vector2 1, 0
  ]
  
  for cluster in clusters
    cluster.points = []
    
    plane = cluster.getPlane()
    horizon = cameraAngle.getHorizon plane.normal

    # Start with cluster pixels.
    pixels = []

    for pixel in cluster.pixels
      pixels.push pixel

      # Also add connections between neighbors at half the distance, but only if it's an edge pixel.
      allDirectionsAreSameCluster = true

      for direction in pixelDirections
        unless pixel[direction.property]?.cluster is cluster
          allDirectionsAreSameCluster = false
          break

      continue if allDirectionsAreSameCluster

      for direction in pixelDirections
        continue unless pixel[direction.property]?.cluster is cluster

        pixels.push
          x: pixel.x + direction.vector.x * 0.5
          y: pixel.y + direction.vector.y * 0.5

    for pixelVertex in cameraAngle.projectPoints pixels, plane
      cluster.points.push
        vertex: pixelVertex
        type: LOI.Assets.Engine.Mesh.Cluster.PointTypes.Pixel

    # Add void pixels.
    voidPixels = []
    
    for pixel in cluster.pixels
      for direction in pixelDirections
        continue if pixel[direction.property]
        
        distance = cameraAngle.distanceInDirectionToHorizon new THREE.Vector2(pixel.x, pixel.y), direction.vector, horizon

        # Multiply by direction sign since if it's negative we're moving away from the horizon.
        distance *= (direction.vector.x + direction.vector.y) unless distance is Number.POSITIVE_INFINITY

        # If the pixel is less than half a pixel away from the horizon, we can't produce a valid void pixel.
        continue if distance <= 0.5

        # Use a factor to bring void point 0.5 pixels or more away from the horizon.
        factor = Math.min 1, distance - 0.5

        voidPixels.push
          x: pixel.x + direction.vector.x * factor
          y: pixel.y + direction.vector.y * factor

    voidPointsStart = cluster.points.length

    for voidVertex in cameraAngle.projectPoints voidPixels, plane
      # Make sure this is not a duplicate of another void point.
      duplicate = false

      for voidPointIndex in [voidPointsStart...cluster.points.length]
        if voidVertex.distanceToSquared(cluster.points[voidPointIndex].vertex) < 1e-10
          duplicate = true
          break

      continue if duplicate

      cluster.points.push
        vertex: voidVertex
        type: LOI.Assets.Engine.Mesh.Cluster.PointTypes.Void

    # Add all edges.
    edgePointsStart = cluster.points.length

    for edge in cluster.edges
      line = edge.getLine3()

      # Create edge vertices at double the density.
      edgeVertices = []

      for edgeVertex, index in edge.vertices
        edgeVertices.push edgeVertex

        if index < edge.vertices.length - 1
          nextVertex = edge.vertices[index + 1]

          edgeVertices.push
            x: (edgeVertex.x + nextVertex.x) / 2
            y: (edgeVertex.y + nextVertex.y) / 2

      for edgeVertex in cameraAngle.projectPoints edgeVertices, plane, -0.5, -0.5
        line.closestPointToPoint edgeVertex, false, edgeVertex

        # Make sure this is not a duplicate of another edge point.
        duplicate = false

        for edgePointIndex in [edgePointsStart...cluster.points.length]
          if edgeVertex.distanceToSquared(cluster.points[edgePointIndex].vertex) < 1e-10
            duplicate = true
            break

        continue if duplicate

        cluster.points.push
          vertex: edgeVertex
          type: LOI.Assets.Engine.Mesh.Cluster.PointTypes.Edge

    # Create the base of plane space.
    plane = new THREE.Plane cluster.plane.normal, 0

    unitX = if Math.abs(plane.normal.x) is 1 then new THREE.Vector3 0, 0, 1 else new THREE.Vector3 1, 0, 0
    baseX = new THREE.Vector3
    plane.projectPoint unitX, baseX
    baseX.normalize()

    baseY = new THREE.Vector3().crossVectors baseX, plane.normal

    # Create the matrices to go to and from plane space.
    cluster.plane.matrix = new THREE.Matrix4().makeBasis(baseX, baseY, plane.normal).setPosition cluster.plane.point
    cluster.plane.matrixInverse = new THREE.Matrix4().getInverse cluster.plane.matrix

    # Transform points to plane space.
    planeVector = new THREE.Vector3

    for point in cluster.points
      planeVector.copy(point.vertex).applyMatrix4 cluster.plane.matrixInverse

      # Strip the z component.
      point.vertexPlane = new THREE.Vector2 planeVector.x, planeVector.y

  console.log "Created cluster points", clusters if LOI.Assets.Engine.Mesh.debug
