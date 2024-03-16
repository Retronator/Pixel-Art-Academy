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
    
    centerOfMass = @_calculateCenterOfMass pixelArtEvaluation
    
    new @ centerOfMass, pixelArtEvaluation.layers[0].cores

  constructor: (@bitmapOrigin, @cores) ->
    super arguments...

    @lines = []
    boundingRectangle = null

    for core in @cores
      for line in core.outlines
        points = @constructor._getLinePoints line
        
        for point in points
          point.x -= @bitmapOrigin.x
          point.y -= @bitmapOrigin.y
        
        newBoundingRectangle = @constructor._getBoundingRectangleOfPoints points
        
        if boundingRectangle
          boundingRectangle.union newBoundingRectangle
          
        else
          boundingRectangle = newBoundingRectangle
        
        @lines.push points
        
    boundsWidth = boundingRectangle.width() + 1
    boundsHeight = boundingRectangle.height() + 1
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    @height = pixelSize * Math.min boundsWidth, boundsHeight

    centerOfMassHeightPercentage = 0.1
    @topY = @height * (1 - centerOfMassHeightPercentage)
    @bottomY = -@height * centerOfMassHeightPercentage
  
  createPhysicsDebugGeometry: ->
    geometryData = @constructor._createExtrudedVerticesAndIndices @lines, @topY, @bottomY

    geometry = new THREE.BufferGeometry
    geometry.setAttribute 'position', new THREE.BufferAttribute geometryData.vertices, 3
    geometry.setIndex new THREE.BufferAttribute geometryData.indices, 1
    geometry.computeBoundingBox()
    geometry

  createCollisionShape: ->
    @convexHullShape = new Ammo.btConvexHullShape()
    hullPoint = Ammo.btVector3.zero()
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    for line in @lines
      for point, pointIndex in line
        hullPoint.setX (point.x + 0.5) * pixelSize
        hullPoint.setY @topY
        hullPoint.setZ (point.y + 0.5) * pixelSize
        @convexHullShape.addPoint hullPoint
        
        hullPoint.setY -@bottomY
        recalculateLocalAABB = pointIndex is line.length - 1
        @convexHullShape.addPoint hullPoint, recalculateLocalAABB
    
    @convexHullShape

  yPosition: -> -@bottomY
