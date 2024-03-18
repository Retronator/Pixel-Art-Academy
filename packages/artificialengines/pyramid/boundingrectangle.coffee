AP = Artificial.Pyramid

class AP.BoundingRectangle
  @fromVertices: (vertices) ->
    minX = _.minBy(vertices, (vertex) => vertex.x).x
    maxX = _.maxBy(vertices, (vertex) => vertex.x).x
    minY = _.minBy(vertices, (vertex) => vertex.y).y
    maxY = _.maxBy(vertices, (vertex) => vertex.y).y
    
    new @ minX, maxX, minY, maxY
    
  constructor: (@minX, @maxX, @minY, @maxY) ->
    @width = @maxX - @minX
    @height = @maxY - @minY
    @area = @width * @height
    
    @center =
      x: @minX + @width / 2
      y: @minY + @height / 2
