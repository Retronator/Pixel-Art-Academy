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
      
      for line in core.outlines
        points = @_getLinePoints line
        boundary = new AP.PolygonBoundary points
        boundaries.push boundary
        
        for point, pointIndex in points
          boundary.vertices[pointIndex].tangent = point.tangent
      
      polygon = new AP.PolygonWithHoles boundaries
      topPolygon = polygon.getInsetPolygon taperDistanceTop
      bottomPolygon = polygon.getInsetPolygon taperDistanceBottom

      try
        topPolygonWithoutHoles = topPolygon.getPolygonWithoutHoles()
        bottomPolygonWithoutHoles = bottomPolygon.getPolygonWithoutHoles()
        
      catch error
        # Looks like the holes weren't able to be removed, so try an inset with just the outer boundary.
        polygon = new AP.PolygonWithHoles polygon.externalBoundary, []
        topPolygon = polygon.getInsetPolygon taperDistanceTop
        bottomPolygon = polygon.getInsetPolygon taperDistanceBottom

        topPolygonWithoutHoles = topPolygon.getPolygonWithoutHoles()
        bottomPolygonWithoutHoles = bottomPolygon.getPolygonWithoutHoles()
        
      for boundary, boundaryIndex in polygon.boundaries
        for vertex, vertexIndex in boundary.vertices
          for taperedBoundary in [topPolygon.boundaries[boundaryIndex], bottomPolygon.boundaries[boundaryIndex]]
            taperedBoundary.vertices[vertexIndex].tangent = vertex.tangent
      
      individualGeometryData.push @constructor._createTaperedVerticesAndIndices bottomPolygon.boundaries, topPolygon.boundaries,  -@height, 0, @properties.flipped
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices topPolygonWithoutHoles, 0, 1
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices bottomPolygonWithoutHoles, -@height, -1
    
      @boundaries.push boundaries...
      @taperedBoundariesTop.push topPolygon.boundaries...
      @taperedBoundariesBottom.push bottomPolygon.boundaries...
      
    @geometryData = @constructor._mergeGeometryData individualGeometryData

  positionY: -> @properties.positionY or @height
