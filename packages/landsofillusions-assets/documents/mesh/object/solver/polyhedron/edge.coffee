LOI = LandsOfIllusions

class LOI.Assets.Mesh.Object.Solver.Polyhedron.Edge
  constructor: (@clusterA, @clusterB) ->
    # Note: Edge segments are directed so that cluster A is on the right of the segment, cluster B on the left.
    @segments = []
    @segmentsMap = {}

    @line =
      point: null
      direction: new THREE.Vector3().crossVectors @clusterA.plane.normal, @clusterB.plane.normal

    @startRecomputation()

  startRecomputation: ->
    # Note: Edge vertices are located in the top-left corner of the pixel at their vertex coordinates.
    @vertices = []
    @verticesMap = {}

    @changed = false

    # Mark all segments as not added.
    segment.added = false for segment in @segments

  endRecomputation: ->
    # See if all segments were re-added.
    for segment in @segments
      unless segment.added
        # A segment was not added, so it must have been removed and this edge has changed.
        @changed = true
        @segmentsMap[segment[0].x][segment[0].y][segment[1].x][segment[1].y] = null

    _.remove @segments, (segment) -> not segment.added

  addSegment: (coordinates, startXOffset, startYOffset, endXOffset, endYOffset) ->
    start =
      x: coordinates.x + startXOffset
      y: coordinates.y + startYOffset

    end =
      x: coordinates.x + endXOffset
      y: coordinates.y + endYOffset

    if existingSegment = @segmentsMap[start.x]?[start.y]?[end.x]?[end.y]
      existingSegment.added = true

    else
      segment = [start, end]
      segment.added = true

      @segments.push segment

      @segmentsMap[start.x] ?= {}
      @segmentsMap[start.x][start.y] ?= {}
      @segmentsMap[start.x][start.y][end.x] ?= {}
      @segmentsMap[start.x][start.y][end.x][end.y] = segment

      @changed = true

    @_addVertex start
    @_addVertex end

  _addVertex: (vertex) ->
    return if @findVertex vertex.x, vertex.y

    @vertices.push vertex

    @verticesMap[vertex.x] ?= {}
    @verticesMap[vertex.x][vertex.y] = vertex

  process: ->
    # If direction has no length, it's a result of a cross product between two coplanar clusters.
    @coplanarClusters = true unless @line.direction.length()

  caluclateLinePoint: ->
    # We assume both clusters have their planes fully determined, which means this edge is fully determined too.
    @line.point = new THREE.Vector3
    @clusterA.getPlane().projectPoint @clusterB.plane.point, @line.point

  addToClusters: ->
    @clusterA.addEdge @
    @clusterB.addEdge @

  removeFromClusters: ->
    @clusterA.removeEdge @
    @clusterB.removeEdge @
    
  reportChangeToClusters: ->
    @clusterA.edgesChanged = true
    @clusterB.edgesChanged = true

  getOtherCluster: (cluster) ->
    if @clusterA is cluster then @clusterB else @clusterA

  findVertex: (x, y) ->
    @verticesMap[x]?[y]

  getLine3: ->
    new THREE.Line3 @line.point, @line.point.clone().add @line.direction

  getLineSegments: (cameraAngle) ->
    lineSegments = new THREE.LineSegments
    lineSegments.material.color = new THREE.Color 0xbc8c4c

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

    lineSegments.geometry.addAttribute 'position', new THREE.BufferAttribute verticesArray, elementsPerVertex

    lineSegments
