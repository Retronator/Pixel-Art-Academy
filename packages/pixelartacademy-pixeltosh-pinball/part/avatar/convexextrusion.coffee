AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.ConvexExtrusion extends Pinball.Part.Avatar.Shape
  @centerOfMassHeightPercentage = 0.1

  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].cores.length
    
    new @ pixelArtEvaluation

  constructor: (@pixelArtEvaluation) ->
    super arguments...
    
    @bitmapOrigin = @constructor._calculateCenterOfMass @pixelArtEvaluation
    
    @cores = @pixelArtEvaluation.layers[0].cores

    @lines = []
    @bitmapBoundingRectangle = null

    for core in @cores
      for line in core.outlines
        points = @constructor._getLinePoints line
        
        for point in points
          point.x -= @bitmapOrigin.x
          point.y -= @bitmapOrigin.y
        
        newBoundingRectangle = @constructor._getBoundingRectangleOfPoints points
        
        if @bitmapBoundingRectangle
          @bitmapBoundingRectangle.union newBoundingRectangle
          
        else
          @bitmapBoundingRectangle = newBoundingRectangle
        
        @lines.push points
    
    @bitmapBoundingRectangle = @bitmapBoundingRectangle.extrude 0, 1, 1, 0

    pixelSize = Pinball.CameraManager.orthographicPixelSize
    @width = @bitmapBoundingRectangle.width() * pixelSize
    @depth = @bitmapBoundingRectangle.height() * pixelSize
    @height = Math.min(@bitmapBoundingRectangle.width(), @bitmapBoundingRectangle.height()) * pixelSize
    
    @topY = @height * (1 - @constructor.centerOfMassHeightPercentage)
    @bottomY = -@height * @constructor.centerOfMassHeightPercentage
  
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
        
        hullPoint.setY -@bottomY
        convexHullShape.addPoint hullPoint
        
    convexHullShape.recalcLocalAabb()
    convexHullShape

  yPosition: -> -@bottomY
