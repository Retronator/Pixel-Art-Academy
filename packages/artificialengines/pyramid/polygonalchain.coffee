AP = Artificial.Pyramid

class AP.PolygonalChain
  constructor: (@vertices) ->
  
  isClosed: ->
    @vertices[0].equals _.last @vertices
    
  getPolygonBoundary: ->
    return null unless @isClosed()
    
    new AP.PolygonBoundary(@vertices[0..@vertices.length - 2])
  
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
