LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Edges
  constructor: (@meshCanvas) ->
    
  drawToContext: (context) ->
    return unless @meshCanvas.edgesEnabled()
    return unless objects = @meshCanvas.meshData()?.objects.getAll()

    context.strokeStyle = "#bc8c4c"
    context.lineWidth = 0.2

    for object in objects
      context.beginPath()

      for edge in object.solver.edges
        for segment in edge.segments
          context.moveTo segment[0].x, segment[0].y
          context.lineTo segment[1].x, segment[1].y

      context.stroke()
