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
    taperDistance = @properties.taperDistance / Pinball.CameraManager.orthographicPixelSize
    
    @boundaries = []
    @taperedBoundaries = []
    
    for core in @pixelArtEvaluation.layers[0].cores
      boundaries = []
      taperedBoundaries = []
      
      for line in core.outlines
        points = @_getLinePoints line
        boundary = new AP.PolygonBoundary points
        taperedBoundary = boundary.getInsetPolygonBoundary taperDistance
        boundaries.push boundary
        taperedBoundaries.push taperedBoundary
      
      @boundaries.push boundaries...
      @taperedBoundaries.push taperedBoundaries...

      polygon = new AP.PolygonWithHoles boundaries
      polygonWithoutHoles = polygon.getPolygonWithoutHoles()
      
      taperedPolygon = new AP.PolygonWithHoles taperedBoundaries
      taperedPolygonWithoutHoles = taperedPolygon.getPolygonWithoutHoles()
      
      if @properties.taperTop
        topPolygon = taperedPolygon
        topPolygonWithoutHoles = taperedPolygonWithoutHoles
        bottomPolygon = polygon
        bottomPolygonWithoutHoles = polygonWithoutHoles
        
      else
        topPolygon = polygon
        topPolygonWithoutHoles = polygonWithoutHoles
        bottomPolygon = taperedPolygon
        bottomPolygonWithoutHoles = taperedPolygonWithoutHoles
        
      individualGeometryData.push @constructor._createTaperedVerticesAndIndices bottomPolygon.boundaries, topPolygon.boundaries,  -@height, 0, @properties.flipped
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices topPolygonWithoutHoles, 0, 1
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices bottomPolygonWithoutHoles, -@height, -1
    
    @geometryData = @constructor._mergeGeometryData individualGeometryData

  positionY: -> @properties.positionY or @height
