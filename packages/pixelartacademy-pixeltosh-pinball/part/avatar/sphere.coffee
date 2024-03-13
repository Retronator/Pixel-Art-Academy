AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Sphere extends Pinball.Part.Avatar
  collisionShapeMargin: -> null

  createGeometry: ->
    new THREE.SphereBufferGeometry @properties.radius, 32, 32

  createCollisionShape: ->
    new Ammo.btSphereShape @properties.radius
    
  yPosition: ->
    @properties.radius
