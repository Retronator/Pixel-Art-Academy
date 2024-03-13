AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.Box extends Pinball.Part.Avatar
  createGeometry: ->
    size = @properties.size
    new THREE.BoxBufferGeometry size.x, size.y, size.z

  createCollisionShape: ->
    size = @properties.size
    new Ammo.btBoxShape new Ammo.btVector3 size.x / 2, size.y / 2, size.z / 2

  yPosition: ->
    @properties.size.y / 2
