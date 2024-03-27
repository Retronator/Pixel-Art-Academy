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
      wallLines = []
      
      for line in core.outlines
        points = @_getLinePoints line
        wallLines.push points
        boundaries.push new AP.PolygonBoundary points
      
      geometryData = @constructor._createExtrudedVerticesAndIndices wallLines, 0, -@height, @properties.flipped
      _.reverse geometryData.indexBufferArray if @properties.flipped
      individualGeometryData.push geometryData
      
      polygon = new AP.PolygonWithHoles boundaries
      
      topPolygon = polygon.getPolygonWithoutHoles()
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices topPolygon, 0
      @boundaries.push boundaries...
    
    @geometryData = @constructor._mergeGeometryData individualGeometryData

  yPosition: -> @height
