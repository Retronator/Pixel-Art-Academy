AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Cylinder extends Pinball.Part.Avatar
  collisionShapeMargin: -> null

  createGeometry: ->
    new THREE.CylinderBufferGeometry @properties.radius, @properties.radius, @properties.height, 32

  createCollisionShape: ->
    new Ammo.btCylinderShape new Ammo.btVector3 @properties.radius, @properties.height / 2, @properties.radius

  yPosition: ->
    @properties.height / 2
