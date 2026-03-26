AE = Artificial.Everywhere
AS = Artificial.Spectrum
AP = Artificial.Pyramid
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Shape
  @RotationStyles:
    Fixed: 'Fixed'
    Perpendicular: 'Perpendicular'
    Free: 'Free'
  
  @MeshStyles:
    Plane: 'Plane'
    Extrusion: 'Extrusion'
  
  @roughEdgeMargin = 0.002 # m
  @curveExtraPointsCount = 2
  
  @detectShape: (pixelArtEvaluation, properties) -> throw new AE.NotImplementedException "A part shape must create a shape instance if it can be detected."
  
  @_detectCircle: (pixelArtEvaluation) ->
    layer = pixelArtEvaluation.layers[0]

    # If we have no cores, try to detect if points themselves form a circle.
    if layer.cores.length is 0
      points = layer.points
      return unless points.length

      allowInsidePoints = true
      
    else
      # Otherwise, we must have only one core and line.
      return unless layer.cores.length is 1 and layer.lines.length is 1
      
      # Some parts of the line must be curves.
      line = layer.lines[0]
      return unless _.some line.pointPartIsCurve
      
      points = line.points
    
    # See if points form a circle.
    center = new THREE.Vector2
    center.add point for point in points
    center.multiplyScalar 1 / points.length
    
    distancesFromCenter = for point in points
      center.distanceTo point

    if allowInsidePoints
      radius = _.max distancesFromCenter

    else
      radius = _.sum(distancesFromCenter) / distancesFromCenter.length

    deviationsFromRadius = for distanceFromCenter in distancesFromCenter
      if allowInsidePoints
        Math.max 0, distanceFromCenter - radius
        
      else
        Math.abs distanceFromCenter - radius
      
    # We allow for a half a pixel deviation from the radius (this makes a 5x5 square fall outside the range).
    return if _.max(deviationsFromRadius) > 0.5

    center.x += 0.5
    center.y += 0.5
    radius += 0.5

    position: center
    radius: radius
    
  @_getBoundingRectangleOfPoints: (points) ->
    bounds =
      left: Number.POSITIVE_INFINITY
      top: Number.POSITIVE_INFINITY
      right: Number.NEGATIVE_INFINITY
      bottom: Number.NEGATIVE_INFINITY

    bounds.left = Math.min bounds.left, _.minBy(points, (point) => point.x).x
    bounds.top = Math.min bounds.top, _.minBy(points, (point) => point.y).y
    bounds.right = Math.max bounds.right, _.maxBy(points, (point) => point.x).x
    bounds.bottom = Math.max bounds.bottom, _.maxBy(points, (point) => point.y).y
    
    new AE.Rectangle bounds

  @_calculateCenterOfMass: (pixelArtEvaluation) ->
    pixels = pixelArtEvaluation.layers[0].pixels
    center = new THREE.Vector2
    
    center.add pixel for pixel in pixels
    center.multiplyScalar 1 / pixels.length

    center.x += 0.5
    center.y += 0.5
    center
    
  @_createExtrudedVerticesAndIndices: (polygonBoundaries, bottomY, topY, flipped = false) ->
    vertexCount = _.sumBy polygonBoundaries, (polygonBoundary) => polygonBoundary.vertices.length
    
    vertexBufferArray = new Float32Array vertexCount * 6
    normalArray = new Float32Array vertexCount * 6
    indexBufferArray = new Uint32Array vertexCount * 6
    
    boundaryStartVertexIndex = 0
    currentIndex = 0
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    normalSign = if flipped then -1 else 1
    
    for polygonBoundary in polygonBoundaries
      bottomVertexIndex = boundaryStartVertexIndex
      topVertexIndex = bottomVertexIndex + 1
      
      for vertex, vertexIndex in polygonBoundary.vertices
        x = vertex.x * pixelSize
        y = vertex.y * pixelSize
        vertexBufferArray[bottomVertexIndex * 3] = x
        vertexBufferArray[bottomVertexIndex * 3 + 1] = bottomY
        vertexBufferArray[bottomVertexIndex * 3 + 2] = y
        vertexBufferArray[topVertexIndex * 3] = x
        vertexBufferArray[topVertexIndex * 3 + 1] = topY
        vertexBufferArray[topVertexIndex * 3 + 2] = y
        
        normalArray[bottomVertexIndex * 3] = -vertex.tangent.y * normalSign
        normalArray[bottomVertexIndex * 3 + 2] = vertex.tangent.x * normalSign
        normalArray[topVertexIndex * 3] = -vertex.tangent.y * normalSign
        normalArray[topVertexIndex * 3 + 2] = vertex.tangent.x * normalSign
        
        nextBottomVertexIndex = if vertexIndex is polygonBoundary.vertices.length - 1 then boundaryStartVertexIndex else bottomVertexIndex + 2
        nextTopVertexIndex = nextBottomVertexIndex + 1
        
        indexBufferArray[currentIndex] = nextBottomVertexIndex
        indexBufferArray[currentIndex + 1] = bottomVertexIndex
        indexBufferArray[currentIndex + 2] = nextTopVertexIndex
        indexBufferArray[currentIndex + 3] = topVertexIndex
        indexBufferArray[currentIndex + 4] = nextTopVertexIndex
        indexBufferArray[currentIndex + 5] = bottomVertexIndex
        
        bottomVertexIndex += 2
        topVertexIndex += 2
        currentIndex += 6
      
      boundaryStartVertexIndex += polygonBoundary.vertices.length * 2
    
    {vertexBufferArray, normalArray, indexBufferArray}
  
  @_createTaperedVerticesAndIndices: (bottomPolygonBoundaries, topPolygonBoundaries, bottomY, topY, flipped = false) ->
    vertexCount = _.sumBy bottomPolygonBoundaries, (polygonBoundary) => polygonBoundary.vertices.length
    
    vertexBufferArray = new Float32Array vertexCount * 6
    normalArray = new Float32Array vertexCount * 6
    indexBufferArray = new Uint32Array vertexCount * 6
    
    boundaryStartVertexIndex = 0
    currentIndex = 0
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    normalSign = if flipped then -1 else 1
    
    for polygonBoundaryIndex in [0...bottomPolygonBoundaries.length]
      bottomPolygonBoundary = bottomPolygonBoundaries[polygonBoundaryIndex]
      topPolygonBoundary = topPolygonBoundaries[polygonBoundaryIndex]
      
      bottomVertexIndex = boundaryStartVertexIndex
      topVertexIndex = bottomVertexIndex + 1
      
      for vertexIndex in [0...bottomPolygonBoundary.vertices.length]
        bottomVertex = bottomPolygonBoundary.vertices[vertexIndex]
        topVertex = topPolygonBoundary.vertices[vertexIndex]
        
        vertexBufferArray[bottomVertexIndex * 3] = bottomVertex.x * pixelSize
        vertexBufferArray[bottomVertexIndex * 3 + 1] = bottomY
        vertexBufferArray[bottomVertexIndex * 3 + 2] = bottomVertex.y * pixelSize
        vertexBufferArray[topVertexIndex * 3] = topVertex.x * pixelSize
        vertexBufferArray[topVertexIndex * 3 + 1] = topY
        vertexBufferArray[topVertexIndex * 3 + 2] = topVertex.y * pixelSize
        
        normalArray[bottomVertexIndex * 3] = -bottomVertex.tangent.y * normalSign
        normalArray[bottomVertexIndex * 3 + 2] = bottomVertex.tangent.x * normalSign
        normalArray[topVertexIndex * 3] = -topVertex.tangent.y * normalSign
        normalArray[topVertexIndex * 3 + 2] = topVertex.tangent.x * normalSign
        
        nextBottomVertexIndex = if vertexIndex is bottomPolygonBoundary.vertices.length - 1 then boundaryStartVertexIndex else bottomVertexIndex + 2
        nextTopVertexIndex = nextBottomVertexIndex + 1
        
        indexBufferArray[currentIndex] = nextBottomVertexIndex
        indexBufferArray[currentIndex + 1] = bottomVertexIndex
        indexBufferArray[currentIndex + 2] = nextTopVertexIndex
        indexBufferArray[currentIndex + 3] = topVertexIndex
        indexBufferArray[currentIndex + 4] = nextTopVertexIndex
        indexBufferArray[currentIndex + 5] = bottomVertexIndex
        
        bottomVertexIndex += 2
        topVertexIndex += 2
        currentIndex += 6
      
      boundaryStartVertexIndex += bottomPolygonBoundary.vertices.length * 2
    
    {vertexBufferArray, normalArray, indexBufferArray}
    
  @_createPolygonVerticesAndIndices: (polygon, y, normalY) ->
    vertexBufferArray = new Float32Array polygon.vertices.length * 3
    normalArray = new Float32Array polygon.vertices.length * 3
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    for vertex, vertexIndex in polygon.vertices
      offset = vertexIndex * 3
      vertexBufferArray[offset] = vertex.x * pixelSize
      vertexBufferArray[offset + 1] = y
      vertexBufferArray[offset + 2] = vertex.y * pixelSize
      
      normalArray[offset + 1] = normalY
    
    indexBufferArray = polygon.triangulate true
    console.warn "Shape was not able to be triangulated fully.", polygon if indexBufferArray.error
    _.reverse indexBufferArray unless normalY < 0
    
    {vertexBufferArray, normalArray, indexBufferArray}
  
  @_createLineVerticesAndIndices: (points, radialSegmentsCount, joinDistance) ->
    positions = []
    radii = []
    tangents = []
    normals = []
    binormals = []
    
    for point in points
      if point.outgoingTangent
        position1 = new THREE.Vector3().copy(point.tangent).multiplyScalar(-joinDistance).add point.position
        position2 = new THREE.Vector3().copy(point.outgoingTangent).multiplyScalar(joinDistance).add point.position
        positions.push position1, position2
        tangents.push point.tangent, point.outgoingTangent
        normals.push point.normal, point.outgoingNormal or point.normal
        binormals.push new THREE.Vector3().crossVectors(point.tangent, point.normal), new THREE.Vector3().crossVectors(point.outgoingTangent, point.outgoingNormal or point.normal)
        radii.push point.radius, point.radius
      
      else
        positions.push point.position
        tangents.push point.tangent
        normals.push point.normal
        binormals.push new THREE.Vector3().crossVectors point.tangent, point.normal
        radii.push point.radius
    
    vertexBufferArray = new Float32Array positions.length * radialSegmentsCount * 3
    normalArray = new Float32Array positions.length * radialSegmentsCount * 3
    currentVertexIndex = 0
    currentVertexBufferOffset = 0
  
    for position, segmentIndex in positions
      normal = normals[segmentIndex]
      binormal = binormals[segmentIndex]
      radius = radii[segmentIndex]
      
      for radialSegmentIndex in [0...radialSegmentsCount]
        circleRatio = radialSegmentIndex / radialSegmentsCount * Math.PI * 2
        circleRatioSin = Math.sin circleRatio
        circleRatioCos = Math.cos circleRatio
        
        normalX = circleRatioCos * normal.x + circleRatioSin * binormal.x
        normalY = circleRatioCos * normal.y + circleRatioSin * binormal.y
        normalZ = circleRatioCos * normal.z + circleRatioSin * binormal.z
        normalArray[currentVertexBufferOffset] = normalX
        normalArray[currentVertexBufferOffset + 1] = normalY
        normalArray[currentVertexBufferOffset + 2] = normalZ
        
        vertexBufferArray[currentVertexBufferOffset] = position.x + radius * normalX
        vertexBufferArray[currentVertexBufferOffset + 1] = position.y + radius * normalY
        vertexBufferArray[currentVertexBufferOffset + 2] = position.z + radius * normalZ
        currentVertexBufferOffset += 3
        currentVertexIndex++
        
    indexBufferArray = new Uint32Array (positions.length - 1) * radialSegmentsCount * 6
    currentIndex = 0
    
    for segmentIndex in [0...positions.length]
      segmentStartVertexIndex = segmentIndex * radialSegmentsCount

      for radialSegmentIndexA in [0...radialSegmentsCount]
        radialSegmentIndexB = (radialSegmentIndexA + 1) % radialSegmentsCount
        
        quadStartVertexIndexA = segmentStartVertexIndex + radialSegmentIndexA
        quadStartVertexIndexB = segmentStartVertexIndex + radialSegmentIndexB
        quadEndVertexIndexA = quadStartVertexIndexA + radialSegmentsCount
        quadEndVertexIndexB = quadStartVertexIndexB + radialSegmentsCount
        
        indexBufferArray[currentIndex] = quadEndVertexIndexA
        indexBufferArray[currentIndex + 1] = quadStartVertexIndexA
        indexBufferArray[currentIndex + 2] = quadStartVertexIndexB
        indexBufferArray[currentIndex + 3] = quadEndVertexIndexA
        indexBufferArray[currentIndex + 4] = quadStartVertexIndexB
        indexBufferArray[currentIndex + 5] = quadEndVertexIndexB
        currentIndex += 6
    
    {vertexBufferArray, normalArray, indexBufferArray}
    
  @_mergeGeometryData: (individualGeometryData) ->
    vertexCount = _.sumBy individualGeometryData, (geometryData) => geometryData.vertexBufferArray.length
    indexCount = _.sumBy individualGeometryData, (geometryData) => geometryData.indexBufferArray.length
    
    vertexBufferArray = new Float32Array vertexCount
    normalArray = new Float32Array vertexCount
    indexBufferArray = new Uint32Array indexCount
    vertexOffset = 0
    indexOffset = 0
    
    for geometryData in individualGeometryData
      vertexBufferOffset = vertexOffset * 3
      for vertexCoordinate, vertexCoordinateIndex in geometryData.vertexBufferArray
        vertexBufferArray[vertexBufferOffset + vertexCoordinateIndex] = vertexCoordinate
        normalArray[vertexBufferOffset + vertexCoordinateIndex] = geometryData.normalArray[vertexCoordinateIndex]
        
      for localVertexIndex, indexOfIndex in geometryData.indexBufferArray
        globalVertexIndex = localVertexIndex + vertexOffset
        indexBufferArray[indexOffset + indexOfIndex] = globalVertexIndex
        
      vertexOffset += geometryData.vertexBufferArray.length / 3
      indexOffset += geometryData.indexBufferArray.length
      
    {vertexBufferArray, normalArray, indexBufferArray}

  constructor: (@pixelArtEvaluation, @properties) ->
    @bitmapRectangle = @constructor._getBoundingRectangleOfPoints(@pixelArtEvaluation.layers[0].points).extrude 0, 1, 1, 0
    @bitmapOrigin = @properties.bitmapOrigin or @bitmapRectangle.center()
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    @width = @bitmapRectangle.width() * pixelSize
    @depth = @bitmapRectangle.height() * pixelSize
    @height = @properties.height or Math.min @width, @depth
  
  _getLinePoints: (line, removeLastClosedPoint = true) ->
    points = []
    
    addPoint = (coordinates, tangent, radius) =>
      coordinates = new THREE.Vector2 coordinates.x - @bitmapOrigin.x + 0.5, coordinates.y - @bitmapOrigin.y + 0.5
      tangent = new THREE.Vector2().copy tangent
      points.push _.extend coordinates, {tangent, radius}
    
    curvePointsCount = @constructor.curveExtraPointsCount + 1
    
    for part in line.parts
      if part instanceof PAE.Line.Part.StraightLine
        tangent = new THREE.Vector2()
        part.displayLine2.delta tangent
        tangent.normalize()
        
        if points.length
          lastPoint = _.last points
          lastPoint.outgoingTangent = tangent.clone() unless Math.abs(tangent.x - lastPoint.tangent.x) < Number.EPSILON and Math.abs(tangent.y - lastPoint.tangent.y) < Number.EPSILON
        
        else
          addPoint part.displayLine2.start, tangent, part.points[0].radius
        
        addPoint part.displayLine2.end, tangent, _.last(part.points).radius
      
      if part instanceof PAE.Line.Part.Curve
        addPoint part.displayPoints[0].position, part.displayPoints[0].tangent, part.points[0].radius unless points.length
        previousPoint = part.displayPoints[0]
        
        lastPointIndex = part.displayPoints.length - if part.isClosed then 0 else 1
        
        for pointIndex in [1..lastPointIndex]
          point = part.displayPoints[_.modulo pointIndex, part.displayPoints.length]
          
          for curvePointIndex in [1..curvePointsCount]
            parameter = curvePointIndex / curvePointsCount
            position = AP.BezierCurve.getPointOnCubicBezierCurve previousPoint.position, previousPoint.controlPoints.after, point.controlPoints.before, point.position, parameter
            tangent = new THREE.Vector2().lerpVectors previousPoint.tangent, point.tangent, parameter
            samplePointIndex = Math.round (part.points.length - 1) * parameter
            radius = part.points[samplePointIndex].radius
            addPoint position, tangent, radius
          
          previousPoint = point
    
    points.splice points.length - 1, 1 if line.isClosed and removeLastClosedPoint
    
    if @properties.flipped
      for point in points
        point.x *= -1
        point.tangent.x *= -1
        point.outgoingTangent?.x *= -1
      
    points
    
  positionSnapping: -> true # Override if the shape prohibits snapping of position to pixels.
  
  rotationStyle: -> @constructor.RotationStyles.Perpendicular
  
  meshStyle: -> @constructor.MeshStyles.Plane
  
  collisionShapeMargin: -> @constructor.roughEdgeMargin
  
  createPhysicsDebugGeometry: ->
    throw new AE.NotImplementedException "Part must provide a geometry for debugging physics."
  
  createCollisionShape: ->
    throw new AE.NotImplementedException "Part must provide a collision shape."
  
  positionY: -> @properties.positionY # Override to determine the position from the shape itself.
  
  getBoundingRectangle: ->
    bitmapBoundingRectangle = @bitmapRectangle.toObject()
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    minX = (bitmapBoundingRectangle.left - @bitmapOrigin.x) * pixelSize
    maxX = (bitmapBoundingRectangle.right - @bitmapOrigin.x) * pixelSize
    minY = (bitmapBoundingRectangle.top - @bitmapOrigin.y) * pixelSize
    maxY = (bitmapBoundingRectangle.bottom - @bitmapOrigin.y) * pixelSize
    
    new AP.BoundingRectangle minX, maxX, minY, maxY
  
  getHoleBoundaries: ->
    return unless @holeBoundaries
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize

    for holeBoundary in @holeBoundaries
      vertices = for vertex in holeBoundary.vertices
        new THREE.Vector2().copy(vertex).multiplyScalar pixelSize
        
      new AP.PolygonBoundary vertices
