LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Edge extends THREE.Line
  constructor: (@clusterA, @clusterB) ->
    # We let the original constructor create new geometry and material objects.
    super undefined

    @material.color = new THREE.Color 0xbc8c4c

    # Note: Edge vertices are located in the top-left corner of the pixel at their vertex coordinates.
    @vertices = []

    @line =
      point: null
      direction: new THREE.Vector3().crossVectors @clusterA.plane.normal, @clusterB.plane.normal
  
  addVertices: (pixel, vertex1XOffset, vertex1YOffset, vertex2XOffset, vertex2YOffset) ->
    @_addVertex pixel.x + vertex1XOffset, pixel.y + vertex1YOffset
    @_addVertex pixel.x + vertex2XOffset, pixel.y + vertex2YOffset

  findVertex: (x, y) ->
    _.find @vertices, (vertex) => vertex.x is x and vertex.y is y

  _addVertex: (x, y) ->
    return if @findVertex x, y

    @vertices.push {x, y}

  getLine3: ->
    new THREE.Line3 @line.point, @line.point.clone().add @line.direction

  caluclateLinePoint: ->
    # We assume both clusters have their planes fully determined, which means this edge is fully determined too.
    @line.point = new THREE.Vector3
    @clusterA.getPlane().projectPoint @clusterB.plane.point, @line.point

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

  generateGeometry: (cameraAngle) ->
    elementsPerVertex = 3
    verticesArray = new Float32Array @vertices.length * elementsPerVertex

    plane = if @clusterA.plane.point then @clusterA.getPlane() else @clusterB.getPlane()

    vertices = cameraAngle.projectPoints @vertices, plane, -0.5, -0.5

    line = @getLine3()
    
    vertexOnEdge = new THREE.Vector3

    for vertex, index in vertices
      # Project the vertex onto the edge.
      line.closestPointToPoint vertex, false, vertexOnEdge

      verticesArray[index * elementsPerVertex] = vertexOnEdge.x
      verticesArray[index * elementsPerVertex + 1] = vertexOnEdge.y
      verticesArray[index * elementsPerVertex + 2] = vertexOnEdge.z

    @geometry.addAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex
