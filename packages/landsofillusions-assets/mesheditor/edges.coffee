LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Edges
  constructor: (@options) ->

  drawToContext: (context) ->
    return unless edges = @options.mesh()?.edges()

    context.strokeStyle = "#bc8c4c"
    context.lineWidth = 0.2
    context.beginPath()

    for edge in edges
      for vertex, index in edge.vertices
        if index
          context.lineTo vertex.x, vertex.y

        else
          context.moveTo vertex.x, vertex.y

    context.stroke()
