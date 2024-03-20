AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Depression extends Pinball.Part.Avatar.TriangleMesh
  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].cores.length
    
    new @ pixelArtEvaluation, properties

  constructor: (@pixelArtEvaluation, @properties) ->
    super arguments...
    
    @holeBoundaries = []
    individualGeometryData = []

    for core in @pixelArtEvaluation.layers[0].cores
      boundaries = []
      wallLines = []
      
      for line in core.outlines
        points = @constructor._getLinePoints line
        
        for point in points
          point.x -= @bitmapOrigin.x
          point.x *= -1 if @properties.flipped
          point.y -= @bitmapOrigin.y
          
        wallLines.push points
        boundaries.push new AP.PolygonBoundary points
      
      individualGeometryData.push @constructor._createExtrudedVerticesAndIndices wallLines, @height, 0
      
      polygon = new AP.PolygonWithHoles boundaries
      @holeBoundaries.push polygon.externalBoundary
      
      for internalBoundary in polygon.internalBoundaries
        topPolygon = new AP.Polygon internalBoundary
        individualGeometryData.push @constructor._createPolygonVerticesAndIndices topPolygon, @height
      
      bottomPolygon = polygon.getPolygonWithoutHoles()
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices bottomPolygon, 0
      
    # Merge all geometries.
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
      
    @geometryData = {vertexBufferArray, indexBufferArray}

  yPosition: -> -@height
