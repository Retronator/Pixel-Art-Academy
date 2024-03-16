AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Box extends Pinball.Part.Avatar.Shape
  @detectShape: (pixelArtEvaluation, properties) ->
    return unless pixelArtEvaluation.layers[0].points.length
    
    boundingRectangle = @_getBoundingRectangleOfPoints(pixelArtEvaluation.layers[0].points).extrude 0, 1, 1, 0
    
    new @ boundingRectangle, properties
  
  constructor: (@boundingRectangle, @properties) ->
    super arguments...
    
    @bitmapOrigin = @boundingRectangle.center()
    
    pixelSize = Pinball.CameraManager.orthographicPixelSize
    
    @width = @boundingRectangle.width() * pixelSize
    @depth = @boundingRectangle.height() * pixelSize
    
  collisionShapeMargin: -> null
  
  createPhysicsDebugGeometry: ->
    new THREE.BoxBufferGeometry @width, @properties.height, @depth

  createCollisionShape: ->
    new Ammo.btBoxShape new Ammo.btVector3 @width / 2, @properties.height / 2, @depth / 2

  yPosition: -> @properties.height / 2
