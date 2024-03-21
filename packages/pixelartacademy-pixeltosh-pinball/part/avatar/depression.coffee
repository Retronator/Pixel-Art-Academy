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
        points = @_getLinePoints line
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
    
    @geometryData = @constructor._mergeGeometryData individualGeometryData

  yPosition: -> -@height
