LOI = LandsOfIllusions

LOI.Assets.Mesh.Object.Solver.Polyhedron::projectClusterPoints = (clusters, cameraAngle) ->
  console.log "Projecting cluster points", clusters, cameraAngle if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
  
  pixelDirections = [
    property: 'up', vector: new THREE.Vector2 0, -1
  ,
    property: 'down', vector: new THREE.Vector2 0, 1
  ,
    property: 'left', vector: new THREE.Vector2 -1, 0
  ,
    property: 'right', vector: new THREE.Vector2 1, 0
  ]
  
  orthogonal = not cameraAngle.picturePlaneDistance
  
  for cluster in clusters
    cluster.points = []
    
    plane = cluster.getPlane()
    horizon = cameraAngle.getHorizon plane.normal unless orthogonal

    # Start with cluster pixels.
    pixels = []

    for pixel in cluster.pixels
      # We only need to add pixels on the edges of the cluster.
      allDirectionsAreSameCluster = true

      for direction in pixelDirections
        if pixel.clusterEdges[direction.property]
          allDirectionsAreSameCluster = false
          break

      continue if allDirectionsAreSameCluster

      pixels.push cluster.getAbsolutePixelCoordinates pixel

      # Also add connections between neighbors at half the distance.
      for direction in pixelDirections
        continue if pixel.clusterEdges[direction.property]

        pixels.push cluster.getAbsolutePixelCoordinates
          x: pixel.x + direction.vector.x * 0.5
          y: pixel.y + direction.vector.y * 0.5

    # Project pixels to cluster space.
    pixelVertices = cameraAngle.projectPoints pixels, plane

    for pixelVertex in pixelVertices
      # Make sure this is not a duplicate of another pixel point.
      duplicate = false

      for pixelPoint in cluster.points
        if pixelVertex.manhattanDistanceTo(pixelPoint.vertex) < 1e-10
          duplicate = true
          break

      continue if duplicate

      cluster.points.push
        vertex: pixelVertex
        type: LOI.Assets.Mesh.Object.Solver.Polyhedron.Cluster.PointTypes.Pixel

    # Add void pixels.
    voidPixels = []
    
    for pixel in cluster.pixels
      for direction in pixelDirections
        continue unless pixel.clusterEdges[direction.property]
        
        # Move points away from the horizon in perspective.
        if orthogonal
          factor = 1
          
        else
          position = new THREE.Vector2(pixel.x + cluster.origin.x, pixel.y + cluster.origin.y)
          distance = cameraAngle.distanceInDirectionToHorizon position, direction.vector, horizon

          # The pixel is pointing away from camera if distance to horizon is negative.
          perpendicularDistance = cameraAngle.distanceToHorizon position, horizon
          reverseSide = perpendicularDistance < 0

          unless distance is Number.POSITIVE_INFINITY
            # Negate distance if direction is moving us away from the horizon.
            crossProduct = direction.vector.cross horizon.direction
            distance *= -1 if crossProduct < 0 and not reverseSide or crossProduct > 0 and reverseSide

          # If the pixel is less than half a pixel away from the horizon, we can't produce a valid void pixel.
          continue if distance <= 0.5
  
          # Use a factor to bring void point 0.5 pixels or more away from the horizon.
          factor = Math.min 1, distance - 0.5

        voidPixel = cluster.getAbsolutePixelCoordinates
          x: pixel.x + direction.vector.x * factor
          y: pixel.y + direction.vector.y * factor

        voidPixels.push voidPixel

    voidPointsStart = cluster.points.length

    for voidVertex in cameraAngle.projectPoints voidPixels, plane
      # Make sure this is not a duplicate of another void point.
      duplicate = false

      for voidPointIndex in [voidPointsStart...cluster.points.length]
        if voidVertex.manhattanDistanceTo(cluster.points[voidPointIndex].vertex) < 1e-10
          duplicate = true
          break

      continue if duplicate

      cluster.points.push
        vertex: voidVertex
        type: LOI.Assets.Mesh.Object.Solver.Polyhedron.Cluster.PointTypes.Void

    # Add all edges.
    edgePointsStart = cluster.points.length

    for otherClusterId, edge of cluster.edges
      line = edge.getLine3()

      # Create edge vertices at double the density.
      edgeVertices = []

      for edgeSegment in edge.segments
        # Note: edge segments are already in absolute coordinates.
        edgeVertices.push edgeSegment[0]

        edgeVertices.push
          x: (edgeSegment[0].x + edgeSegment[1].x) / 2
          y: (edgeSegment[0].y + edgeSegment[1].y) / 2

        edgeVertices.push edgeSegment[1]

      for edgeVertex, index in cameraAngle.projectPoints edgeVertices, plane, -0.5, -0.5
        segmentIndex = Math.floor index / 3
        positionInSegment = index % 3

        # Project vertex onto the edge, except for edges with coplanar clusters since those don't have to be straight.
        line.closestPointToPoint edgeVertex, false, edgeVertex unless edge.coplanarClusters

        # See if this is a duplicate of another edge point.
        duplicate = null

        for edgePointIndex in [edgePointsStart...cluster.points.length]
          edgePoint = cluster.points[edgePointIndex]
          if edgeVertex.manhattanDistanceTo(edgePoint.vertex) < 1e-10
            duplicate = edgePoint
            break

        if duplicate
          # We have a duplicate so just notify that this segment starts there.
          duplicate.segments.push {index: segmentIndex, positionInSegment, edge}
          continue

        cluster.points.push
          vertex: edgeVertex
          type: LOI.Assets.Mesh.Object.Solver.Polyhedron.Cluster.PointTypes.Edge
          segments: [{index: segmentIndex, positionInSegment, edge}]

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

    if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
      # Make sure we haven't created any duplicates.
      for point, index in cluster.points
        for otherPoint, otherIndex in cluster.points[index + 1..]
          distance = point.vertexPlane.manhattanDistanceTo otherPoint.vertexPlane
          console.warn "Duplicate point", distance, index, otherIndex, point, otherPoint if distance < 1e-10

  console.log "Created cluster points", clusters if LOI.Assets.Mesh.Object.Solver.Polyhedron.debug
