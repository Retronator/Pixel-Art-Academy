LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Edge
  constructor: (@clusterA, @clusterB) ->
    # Note: Edge vertices are located in the top-left corner of the pixel at their vertex coordinates.
    @vertices = []
  
  addVertices: (pixel, vertex1XOffset, vertex1YOffset, vertex2XOffset, vertex2YOffset) ->
    @_addVertex pixel.x + vertex1XOffset, pixel.y + vertex1YOffset
    @_addVertex pixel.x + vertex2XOffset, pixel.y + vertex2YOffset

  findVertex: (x, y) ->
    _.find @vertices, (vertex) => vertex.x is x and vertex.y is y

  _addVertex: (x, y) ->
    return if @findVertex x, y
  
    @vertices.push {x, y}

  process: ->
    # Calculate vertex neighbors.
    for vertex in @vertices
      for xOffset in [-1..1]
        for yOffset in [-1..1]
          # Make sure exactly one of the offsets is zero
          xIsZero = xOffset is 0
          yIsZero = yOffset is 0
          continue if xIsZero is yIsZero

          continue unless neighborVertex = @findVertex vertex.x + xOffset, vertex.y + yOffset
          if vertex.next
            vertex.previous = neighborVertex

          else
            vertex.next = neighborVertex

    # Find one end of the edge.
    start = _.find @vertices, (vertex) => not vertex.previous

    # Sort the vertices in order.
    vertices = [start]
    currentVertex = start

    while currentVertex.next
      # Make sure previous of the next vertex shows to the current vertex.
      unless currentVertex.next.previous is currentVertex
        currentVertex.next.next = currentVertex.next.previous
        currentVertex.next.previous = currentVertex

      currentVertex = currentVertex.next
      vertices.push currentVertex

    @vertices = vertices
