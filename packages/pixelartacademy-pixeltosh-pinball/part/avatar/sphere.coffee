AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Sphere extends Pinball.Part.Avatar.Shape
  @detectShape: (pixelArtEvaluation) ->
    # We can have a sphere shape if we detect a circle.
    return unless circle = @_detectCircle pixelArtEvaluation
    
    new @ circle.position, circle.radius * Pinball.CameraManager.orthographicPixelSize
  
  constructor: (@bitmapOrigin, @radius) ->
    super arguments...
    
    @continuousCollisionDetectionRadius = @radius
    
  collisionShapeMargin: -> null
  
  constrainRotationToPlayfieldPlane: -> false

  createPhysicsDebugGeometry: ->
    new THREE.SphereBufferGeometry @radius, 8, 4

  createCollisionShape: ->
    new Ammo.btSphereShape @radius
    
  yPosition: -> @radius
