AE = Artificial.Everywhere
AS = Artificial.Spectrum
AP = Artificial.Pyramid
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Shape
  @roughEdgeMargin = 0.002 # m
  @curveExtraPointsCount = 2
  
  @detectShape: (pixelArtEvaluation, properties) -> throw new AE.NotImplementedException "A part shape must create a shape instance if it can be detected."
  
  @_detectCircle: (pixelArtEvaluation) ->
    layer = pixelArtEvaluation.layers[0]

    # If we have no cores, try to detect if points themselves form a circle.
    if layer.cores.length is 0
      points = layer.points
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
    points = pixelArtEvaluation.layers[0].points
    center = new THREE.Vector2
    
    center.add point for point in points
    center.multiplyScalar 1 / points.length
    center
    
  @_createExtrudedVerticesAndIndices: (lines, topY, bottomY, flipped = false) ->
    pointsCount = _.sumBy lines, 'length'
    
    vertexBufferArray = new Float32Array pointsCount * 6
    normalArray = new Float32Array pointsCount * 6
    indexBufferArray = new Uint32Array pointsCount * 6
    
    lineStartVertexIndex = 0
    currentIndex = 0
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    normalSign = if flipped then -1 else 1
    
    for line in lines
      bottomVertexIndex = lineStartVertexIndex
      topVertexIndex = bottomVertexIndex + 1
      
      for point, pointIndex in line
        x = point.x * pixelSize
        y = point.y * pixelSize
        vertexBufferArray[bottomVertexIndex * 3] = x
        vertexBufferArray[bottomVertexIndex * 3 + 1] = topY
        vertexBufferArray[bottomVertexIndex * 3 + 2] = y
        vertexBufferArray[topVertexIndex * 3] = x
        vertexBufferArray[topVertexIndex * 3 + 1] = bottomY
        vertexBufferArray[topVertexIndex * 3 + 2] = y
        
        normalArray[bottomVertexIndex * 3] = -point.tangent.y * normalSign
        normalArray[bottomVertexIndex * 3 + 2] = point.tangent.x * normalSign
        normalArray[topVertexIndex * 3] = -point.tangent.y * normalSign
        normalArray[topVertexIndex * 3 + 2] = point.tangent.x * normalSign
        
        nextBottomVertexIndex = if pointIndex is line.length - 1 then lineStartVertexIndex else bottomVertexIndex + 2
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
      
      lineStartVertexIndex += line.length * 2
    
    {vertexBufferArray, normalArray, indexBufferArray}
    
  @_createPolygonVerticesAndIndices: (polygon, y) ->
    vertexBufferArray = new Float32Array polygon.vertices.length * 3
    normalArray = new Float32Array polygon.vertices.length * 3
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    for vertex, vertexIndex in polygon.vertices
      offset = vertexIndex * 3
      vertexBufferArray[offset] = vertex.x * pixelSize
      vertexBufferArray[offset + 1] = y
      vertexBufferArray[offset + 2] = vertex.y * pixelSize
      
      normalArray[offset + 1] = 1
    
    indexBufferArray = polygon.triangulate()
    _.reverse indexBufferArray
    
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
        
        for point in part.displayPoints[1..]
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
    
  fixedBitmapRotation: -> false # Override if the bitmap should not rotate with the physics object.
  
  collisionShapeMargin: -> @constructor.roughEdgeMargin
  
  createPhysicsDebugGeometry: ->
    throw new AE.NotImplementedException "Part must provide a geometry for debugging physics."
  
  createCollisionShape: ->
    throw new AE.NotImplementedException "Part must provide a collision shape."
  
  yPosition: ->
    throw new AE.NotImplementedException "Part must specify at which y coordinate it should appear."
    
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
