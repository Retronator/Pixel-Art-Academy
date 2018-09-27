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

  console.log "Created cluster points", clusters if LOI.Assets.Engine.Mesh.debug
