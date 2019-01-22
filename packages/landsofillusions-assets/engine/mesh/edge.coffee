LOI = LandsOfIllusions

class LOI.Assets.Engine.Mesh.Edge extends THREE.LineSegments
  constructor: (@clusterA, @clusterB) ->
    # We let the original constructor create new geometry and material objects.
    super undefined

    @material.color = new THREE.Color 0xbc8c4c

    # Note: Edge vertices are located in the top-left corner of the pixel at their vertex coordinates.
    @vertices = []

    # Note: Edge segments are directed so that cluster A is on the right of the segment, cluster B on the left.
    @segments = []

    @line =
      point: null
      direction: new THREE.Vector3().crossVectors @clusterA.plane.normal, @clusterB.plane.normal

  addSegment: (pixel, sourceCluster, startXOffset, startYOffset, endXOffset, endYOffset) ->
    start =
      x: pixel.x + startXOffset + sourceCluster.origin.x
      y: pixel.y + startYOffset + sourceCluster.origin.y

    end =
      x: pixel.x + endXOffset + sourceCluster.origin.x
      y: pixel.y + endYOffset + sourceCluster.origin.y

    @segments.push [start, end]

    @_addVertex start
    @_addVertex end

  findVertex: (x, y) ->
    _.find @vertices, (vertex) => vertex.x is x and vertex.y is y

  _addVertex: (vertex) ->
    return if @findVertex vertex.x, vertex.y

    @vertices.push vertex

  getLine3: ->
    new THREE.Line3 @line.point, @line.point.clone().add @line.direction

  caluclateLinePoint: ->
    # We assume both clusters have their planes fully determined, which means this edge is fully determined too.
    @line.point = new THREE.Vector3
    @clusterA.getPlane().projectPoint @clusterB.plane.point, @line.point

  generateGeometry: (cameraAngle) ->
    vertices = _.flatten @segments
    plane = if @clusterA.plane.point then @clusterA.getPlane() else @clusterB.getPlane()
    vertices = cameraAngle.projectPoints vertices, plane, -0.5, -0.5

    elementsPerVertex = 3
    verticesArray = new Float32Array vertices.length * elementsPerVertex
    line = @getLine3()
    vertexOnEdge = new THREE.Vector3

    for vertex, index in vertices
      # Project the vertex onto the edge.
      line.closestPointToPoint vertex, false, vertexOnEdge

      verticesArray[index * elementsPerVertex] = vertexOnEdge.x
      verticesArray[index * elementsPerVertex + 1] = vertexOnEdge.y
      verticesArray[index * elementsPerVertex + 2] = vertexOnEdge.z

    @geometry.addAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex
