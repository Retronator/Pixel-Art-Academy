LOI = LandsOfIllusions

LOI.Assets.Engine.Mesh.projectClusterPoints = (clusters, cameraAngle) ->
  console.log "Projecting cluster points", clusters, cameraAngle if LOI.Assets.Engine.Mesh.debug
  
  pixelDirections = [
    property: 'up', x: 0, y: -1
  ,
    property: 'down', x: 0, y: 1
  ,
    property: 'left', x: -1, y: 0
  ,
    property: 'right', x: 1, y: 0
  ]
  
  for cluster in clusters
    cluster.points = []
    
    plane = cluster.getPlane()

    # Start with all cluster pixels.
    for pixelVertex in cameraAngle.projectPoints cluster.pixels, plane
      cluster.points.push
        vertex: pixelVertex
        type: LOI.Assets.Engine.Mesh.Cluster.PointTypes.Pixel

    # Add void pixels.
    voidPixels = []
    
    for pixel in cluster.pixels
      for direction in pixelDirections
        continue if pixel[direction.property]
        
        voidPixels.push
          x: pixel.x + direction.x
          y: pixel.y + direction.y

    for voidVertex in cameraAngle.projectPoints voidPixels, plane
      cluster.points.push
        vertex: voidVertex
        type: LOI.Assets.Engine.Mesh.Cluster.PointTypes.Void

    # Add all edges.
    for edge in cluster.edges
      line = edge.getLine3()

      for edgeVertex in cameraAngle.projectPoints edge.vertices, plane, -0.5, -0.5
        line.closestPointToPoint edgeVertex, false, edgeVertex

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
      planeVector.copy(point.vertex).applyMatrix4 cluster.plane.matrix

      # Strip the z component.
      point.vertexPlane = new THREE.Vector2 planeVector.x, planeVector.y

  console.log "Created cluster points", clusters if LOI.Assets.Engine.Mesh.debug
