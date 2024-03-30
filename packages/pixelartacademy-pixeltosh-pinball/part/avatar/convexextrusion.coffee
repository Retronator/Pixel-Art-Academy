AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.ConvexExtrusion extends Pinball.Part.Avatar.Shape
  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].cores.length
    
    new @ pixelArtEvaluation, properties

  constructor: (@pixelArtEvaluation, @properties) ->
    super arguments...
    
    @bitmapOrigin = @_calculateBitmapOrigin() unless @properties.bitmapOrigin
    
    @topY = @height / 2
    @bottomY = -@height / 2
    
    @boundaries = []
    individualGeometryData = []
    
    for core in @pixelArtEvaluation.layers[0].cores
      boundaries = []
      
      for line in core.outlines
        points = @_getLinePoints line
        boundaries.push new AP.PolygonBoundary points
      
      @boundaries.push boundaries...
      
      polygon = new AP.PolygonWithHoles boundaries
      polygonWithoutHoles = polygon.getPolygonWithoutHoles()
      
      individualGeometryData.push @constructor._createExtrudedVerticesAndIndices polygon.boundaries,  @bottomY, @topY, @properties.flipped
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices polygonWithoutHoles, @bottomY, -1
      individualGeometryData.push @constructor._createPolygonVerticesAndIndices polygonWithoutHoles, @topY, 1
    
    @geometryData = @constructor._mergeGeometryData individualGeometryData

  _calculateBitmapOrigin: -> @constructor._calculateCenterOfMass @pixelArtEvaluation
  
  createPhysicsDebugGeometry: ->
    geometry = new THREE.BufferGeometry
    geometry.setAttribute 'position', new THREE.BufferAttribute @geometryData.vertexBufferArray, 3
    geometry.setAttribute 'normal', new THREE.BufferAttribute @geometryData.normalArray, 3
    geometry.setIndex new THREE.BufferAttribute @geometryData.indexBufferArray, 1
    geometry.computeBoundingBox()
    geometry

  createCollisionShape: ->
    convexHullShape = new Ammo.btConvexHullShape()
    hullPoint = Ammo.btVector3.zero()
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    for boundary in @boundaries
      for vertex in boundary.vertices
        hullPoint.setX vertex.x * pixelSize
        hullPoint.setY @topY
        hullPoint.setZ vertex.y * pixelSize
        convexHullShape.addPoint hullPoint, false
        
        hullPoint.setY @bottomY
        convexHullShape.addPoint hullPoint, false
        
    convexHullShape.recalcLocalAabb()
    convexHullShape

  yPosition: -> -@bottomY
