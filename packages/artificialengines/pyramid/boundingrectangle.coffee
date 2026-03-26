AP = Artificial.Pyramid

class AP.BoundingRectangle
  @fromVertices: (vertices) ->
    minX = _.minBy(vertices, (vertex) => vertex.x).x
    maxX = _.maxBy(vertices, (vertex) => vertex.x).x
    minY = _.minBy(vertices, (vertex) => vertex.y).y
    maxY = _.maxBy(vertices, (vertex) => vertex.y).y
    
    new @ minX, maxX, minY, maxY
    
  @union: (boundingRectangles) ->
    return null unless boundingRectangles.length
    
    minX = _.minBy(boundingRectangles, 'minX').minX
    maxX = _.maxBy(boundingRectangles, 'maxX').maxX
    minY = _.minBy(boundingRectangles, 'minY').minY
    maxY = _.maxBy(boundingRectangles, 'maxY').maxY
    
    new @ minX, maxX, minY, maxY
    
  constructor: (@minX, @maxX, @minY, @maxY) ->
    @width = @maxX - @minX
    @height = @maxY - @minY
    @area = @width * @height
    
    @center =
      x: @minX + @width / 2
      y: @minY + @height / 2
      
  getBoundary: ->
    new AP.PolygonBoundary [
      new THREE.Vector2 @minX, @minY
      new THREE.Vector2 @maxX, @minY
      new THREE.Vector2 @maxX, @maxY
      new THREE.Vector2 @minX, @maxY
    ]
  
  getOffsetBoundingRectangle: (offsetX, offsetY) ->
    new @constructor @minX + offsetX, @maxX + offsetX, @minY + offsetY, @maxY + offsetY
  
  getExtrudedBoundingRectangle: (top, right, bottom, left) ->
    new @constructor @minX - left, @maxX + right, @minY - top, @maxY + bottom
