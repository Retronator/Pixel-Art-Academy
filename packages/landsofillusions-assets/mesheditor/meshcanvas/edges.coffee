LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Edges
  constructor: (@meshCanvas) ->
    
  drawToContext: (context) ->
    return unless @meshCanvas.edgesEnabled()
    return unless objects = @meshCanvas.meshData()?.objects.getAll()

    context.strokeStyle = "#bc8c4c"
    context.lineWidth = 0.2

    currentClusterHelper = @meshCanvas.currentClusterHelper()
    currentCluster = currentClusterHelper.cluster()

    for object in objects
      context.beginPath()

      for edge in object.solver.edges
        continue if @meshCanvas.debugMode() and currentCluster not in [edge.clusterA.layerCluster, edge.clusterB.layerCluster]

        for segment in edge.segments
          context.moveTo segment[0].x, segment[0].y
          context.lineTo segment[1].x, segment[1].y

      context.stroke()
