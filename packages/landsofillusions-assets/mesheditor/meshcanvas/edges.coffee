LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Edges
  constructor: (@meshCanvas) ->
    
  drawToContext: (context) ->
    return unless @meshCanvas.edgesEnabled()
    return unless objects = @meshCanvas.mesh()?.objects()

    context.strokeStyle = "#bc8c4c"
    context.lineWidth = 0.2

    for object in objects
      continue unless edges = object.edges()

      context.beginPath()

      for edge in edges
        for segment in edge.segments
          context.moveTo segment[0].x, segment[0].y
          context.lineTo segment[1].x, segment[1].y

      context.stroke()
