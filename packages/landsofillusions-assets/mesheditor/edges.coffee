LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Edges
  constructor: (@options) ->

  drawToContext: (context) ->
    return unless edges = @options.mesh()?.edges()

    context.strokeStyle = "#bc8c4c"
    context.lineWidth = 0.2
    context.beginPath()

    for edge in edges
      for segment in edge.segments
        context.moveTo segment[0].x, segment[0].y
        context.lineTo segment[1].x, segment[1].y

    context.stroke()
