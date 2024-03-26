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
    
  @_createExtrudedVerticesAndIndices: (lines, topY, bottomY) ->
    pointsCount = _.sumBy lines, 'length'
    
    vertexBufferArray = new Float32Array pointsCount * 6
    indexBufferArray = new Uint32Array pointsCount * 6
    
    lineStartVertexIndex = 0
    currentIndex = 0
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
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
    
    {vertexBufferArray, indexBufferArray}
    
  @_createPolygonVerticesAndIndices: (polygon, y) ->
    vertexBufferArray = new Float32Array polygon.vertices.length * 3
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    for vertex, vertexIndex in polygon.vertices
      offset = vertexIndex * 3
      vertexBufferArray[offset] = vertex.x * pixelSize
      vertexBufferArray[offset + 1] = y
      vertexBufferArray[offset + 2] = vertex.y * pixelSize
    
    indexBufferArray = polygon.triangulate()
    
    {vertexBufferArray, indexBufferArray}
    
  @_mergeGeometryData: (individualGeometryData) ->
    vertexCount = _.sumBy individualGeometryData, (geometryData) => geometryData.vertexBufferArray.length
    indexCount = _.sumBy individualGeometryData, (geometryData) => geometryData.indexBufferArray.length
    
    vertexBufferArray = new Float32Array vertexCount
    indexBufferArray = new Uint32Array indexCount
    vertexOffset = 0
    indexOffset = 0
    
    for geometryData in individualGeometryData
      vertexBufferOffset = vertexOffset * 3
      for vertexCoordinate, vertexCoordinateIndex in geometryData.vertexBufferArray
        vertexBufferArray[vertexBufferOffset + vertexCoordinateIndex] = vertexCoordinate
        
      for localVertexIndex, indexOfIndex in geometryData.indexBufferArray
        globalVertexIndex = localVertexIndex + vertexOffset
        indexBufferArray[indexOffset + indexOfIndex] = globalVertexIndex
        
      vertexOffset += geometryData.vertexBufferArray.length / 3
      indexOffset += geometryData.indexBufferArray.length
      
    {vertexBufferArray, indexBufferArray}

  constructor: (@pixelArtEvaluation, @properties) ->
    @bitmapRectangle = @constructor._getBoundingRectangleOfPoints(@pixelArtEvaluation.layers[0].points).extrude 0, 1, 1, 0
    @bitmapOrigin = @properties.bitmapOrigin or @bitmapRectangle.center()
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    @width = @bitmapRectangle.width() * pixelSize
    @depth = @bitmapRectangle.height() * pixelSize
    @height = @properties.height or Math.min @width, @depth
  
  _getLinePoints: (line) ->
    points = []
    
    curvePointsCount = @constructor.curveExtraPointsCount + 1
    
    for part in line.parts
      if part instanceof PAE.Line.Part.StraightLine
        points.push part.displayLine2.start unless points.length
        points.push part.displayLine2.end
      
      if part instanceof PAE.Line.Part.Curve
        points.push part.displayPoints[0].position unless points.length
        previousPoint = part.displayPoints[0]
        
        for point in part.displayPoints[1..]
          for curvePointIndex in [1..curvePointsCount]
            points.push AP.BezierCurve.getPointOnCubicBezierCurve previousPoint.position, previousPoint.controlPoints.after, point.controlPoints.before, point.position, curvePointIndex / curvePointsCount
          
          previousPoint = point
    
    points.splice points.length - 1, 1 if line.isClosed
    
    for point in points
      localPoint = new THREE.Vector2 point.x - @bitmapOrigin.x + 0.5, point.y - @bitmapOrigin.y + 0.5
      localPoint.x *= -1 if @properties.flipped
      localPoint
    
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
