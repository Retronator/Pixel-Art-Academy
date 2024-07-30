AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Extrusion extends Pinball.Part.Avatar.TriangleMesh
  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].cores.length
    
    new @ pixelArtEvaluation, properties

  constructor: (@pixelArtEvaluation, @properties) ->
    super arguments...
    
    individualGeometryData = []
    
    @boundaries = []
    
    for core in @pixelArtEvaluation.layers[0].cores
      boundaries = []
      
      for line in core.outlines
        points = @_getLinePoints line
        boundaries.push new AP.PolygonBoundary points
      
      @boundaries.push boundaries...

      polygon = new AP.PolygonWithHoles boundaries
      polygonWithoutHoles = polygon.getPolygonWithoutHoles()

      individualGeometryData.push @constructor._createExtrudedVerticesAndIndices polygon.boundaries,  -@height, 0, @properties.flipped
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices polygonWithoutHoles, 0, 1
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices polygonWithoutHoles, -@height, -1
    
    @geometryData = @constructor._mergeGeometryData individualGeometryData

  positionY: -> @properties.positionY or @height
