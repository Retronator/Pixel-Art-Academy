AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Silhouette extends Pinball.Part.Avatar.TriangleMesh
  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].cores.length
    
    new @ pixelArtEvaluation, properties

  constructor: (@pixelArtEvaluation, @properties) ->
    super arguments...
    
    individualGeometryData = []

    for core in @pixelArtEvaluation.layers[0].cores
      boundaries = []
      
      for line in core.outlines
        boundaries.push new AP.PolygonBoundary @_getLinePoints line
      
      polygon = new AP.PolygonWithHoles(boundaries).getPolygonWithoutHoles()
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices polygon, @height, 1
      
    @geometryData = @constructor._mergeGeometryData individualGeometryData

  yPosition: -> 0
