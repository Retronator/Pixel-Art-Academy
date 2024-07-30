AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.TaperedExtrusion extends Pinball.Part.Avatar.TriangleMesh
  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].cores.length
    
    new @ pixelArtEvaluation, properties

  constructor: (@pixelArtEvaluation, @properties) ->
    super arguments...
    
    individualGeometryData = []
    taperDistanceTop = @properties.taperDistanceTop / Pinball.CameraManager.orthographicPixelSize
    taperDistanceBottom = @properties.taperDistanceBottom / Pinball.CameraManager.orthographicPixelSize
    
    @boundaries = []
    @taperedBoundariesTop = []
    @taperedBoundariesBottom = []
    
    for core in @pixelArtEvaluation.layers[0].cores
      boundaries = []
      taperedBoundariesTop = []
      taperedBoundariesBottom = []
      
      for line in core.outlines
        points = @_getLinePoints line
        boundary = new AP.PolygonBoundary points
        boundaries.push boundary

        taperedBoundaryTop = boundary.getInsetPolygonBoundary taperDistanceTop
        taperedBoundariesTop.push taperedBoundaryTop

        taperedBoundaryBottom = boundary.getInsetPolygonBoundary taperDistanceBottom
        taperedBoundariesBottom.push taperedBoundaryBottom
        
        for point, pointIndex in points
          for taperedBoundary in [taperedBoundaryTop, taperedBoundaryBottom]
            taperedBoundary.vertices[pointIndex].tangent = point.tangent
      
      @boundaries.push boundaries...
      @taperedBoundariesTop.push taperedBoundariesTop...
      @taperedBoundariesBottom.push taperedBoundariesBottom...

      topPolygon = new AP.PolygonWithHoles taperedBoundariesTop
      topPolygonWithoutHoles = topPolygon.getPolygonWithoutHoles()
      
      bottomPolygon = new AP.PolygonWithHoles taperedBoundariesBottom
      bottomPolygonWithoutHoles = bottomPolygon.getPolygonWithoutHoles()
      
      individualGeometryData.push @constructor._createTaperedVerticesAndIndices bottomPolygon.boundaries, topPolygon.boundaries,  -@height, 0, @properties.flipped
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices topPolygonWithoutHoles, 0, 1
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices bottomPolygonWithoutHoles, -@height, -1
    
    @geometryData = @constructor._mergeGeometryData individualGeometryData

  positionY: -> @properties.positionY or @height
