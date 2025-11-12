AP = Artificial.Pyramid

_line2 = new THREE.Line2

class AP.PolygonalChain
  constructor: (@vertices) ->
  
  isClosed: ->
    @vertices[0].equals _.last @vertices
    
  getPolygonBoundary: ->
    return null unless @isClosed()
    
    new AP.PolygonBoundary(@vertices[0..@vertices.length - 2])
  
  getDecimatedPolygonalChain: (epsilon) ->
    return new AP.PolygonalChain(_.clone @vertices) if @vertices.length < 3
    
    firstVertex = _.first @vertices
    lastVertex = _.last @vertices
    
    _line2.start.copy firstVertex
    _line2.end.copy lastVertex
    
    maxDistance = Number.NEGATIVE_INFINITY
    maxDistanceIndex = null
    
    for vertexIndex in [1...@vertices.length - 1]
      distance = _line2.getDistanceFromLine @vertices[vertexIndex]
      continue if distance <= maxDistance

      maxDistance = distance
      maxDistanceIndex = vertexIndex
      
    if maxDistance > epsilon
      head = new AP.PolygonalChain @vertices[..maxDistanceIndex]
      tail = new AP.PolygonalChain @vertices[maxDistanceIndex..]
      
      decimatedHead = head.getDecimatedPolygonalChain epsilon
      decimatedTail = tail.getDecimatedPolygonalChain epsilon
      
      new AP.PolygonalChain [decimatedHead.vertices..., decimatedTail.vertices...]
    
    else
      new AP.PolygonalChain [firstVertex, lastVertex]
  
  getSVGPathDString: ->
    startVertex = @vertices[0]
    pathString = "M #{startVertex.x} #{startVertex.y}"
    
    # Note: We can't iterate over @vertices[1..] because vertexIndex would be off by one.
    for vertex, vertexIndex in @vertices when vertexIndex > 0
      if vertexIndex is @vertices.length - 1 and vertex.equals startVertex
        pathString += "Z"
        
      else
        pathString += " L #{vertex.x} #{vertex.y}"
    
    pathString
