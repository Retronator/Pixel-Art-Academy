AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
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
    
    @bitmapOrigin = @constructor._calculateCenterOfMass @pixelArtEvaluation unless @properties.bitmapOrigin
    
    @lines = []

    for core in @pixelArtEvaluation.layers[0].cores
      for line in core.outlines
        points = @constructor._getLinePoints line
        
        for point in points
          point.x -= @bitmapOrigin.x
          point.x *= -1 if @properties.flipped
          point.y -= @bitmapOrigin.y
        
        @lines.push points

    @topY = @height / 2
    @bottomY = -@height / 2
  
  createPhysicsDebugGeometry: ->
    geometryData = @constructor._createExtrudedVerticesAndIndices @lines, @topY, @bottomY

    geometry = new THREE.BufferGeometry
    geometry.setAttribute 'position', new THREE.BufferAttribute geometryData.vertices, 3
    geometry.setIndex new THREE.BufferAttribute geometryData.indices, 1
    geometry.computeBoundingBox()
    geometry

  createCollisionShape: ->
    convexHullShape = new Ammo.btConvexHullShape()
    hullPoint = Ammo.btVector3.zero()
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    for line in @lines
      for point, pointIndex in line
        hullPoint.setX (point.x + 0.5) * pixelSize
        hullPoint.setY @topY
        hullPoint.setZ (point.y + 0.5) * pixelSize
        convexHullShape.addPoint hullPoint
        
        hullPoint.setY @bottomY
        convexHullShape.addPoint hullPoint
        
    convexHullShape.recalcLocalAabb()
    convexHullShape

  yPosition: -> -@bottomY
