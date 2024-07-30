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
      
      for line in core.outlines
        points = @_getLinePoints line
        boundaries.push new AP.PolygonBoundary points
      
      polygon = new AP.PolygonWithHoles boundaries
      polygonWithoutHoles = polygon.getPolygonWithoutHoles()
      
      @holeBoundaries.push polygon.externalBoundary

      # Depression walls are on the inside of the polygon so we have to invert them.
      invertedBoundaries = (boundary.getBoundaryWithInvertedOrientation() for boundary in polygon.boundaries)
      individualGeometryData.push @constructor._createExtrudedVerticesAndIndices invertedBoundaries,  0, @height, not @properties.flipped
      
      # Bottom of the hole is a normal polygon.
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices polygonWithoutHoles, 0, 1
      
      # All the internal islands creat top of the hole polygons.
      for internalBoundary in polygon.internalBoundaries
        topPolygon = new AP.Polygon internalBoundary
        individualGeometryData.push @constructor._createPolygonVerticesAndIndices topPolygon, @height, 1
    
    @geometryData = @constructor._mergeGeometryData individualGeometryData

  positionY: -> @properties.positionY or -@height
