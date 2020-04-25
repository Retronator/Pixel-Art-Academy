AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Cylinder extends PAA.StillLifeStand.Item.ProceduralModel
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Cylinder'
  @initialize()

  createGeometry: ->
    properties = @parentItem.data.properties
    new THREE.CylinderBufferGeometry properties.radius, properties.radius, properties.height, 32

  createCollisionShape: ->
    properties = @parentItem.data.properties
    new Ammo.btCylinderShape new Ammo.btVector3 properties.radius, properties.height / 2, properties.radius
