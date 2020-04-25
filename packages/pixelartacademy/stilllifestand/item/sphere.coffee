AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Sphere extends PAA.StillLifeStand.Item.ProceduralModel
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Sphere'
  @initialize()

  createGeometry: ->
    new THREE.SphereBufferGeometry @parentItem.data.properties.radius, 32, 32

  createCollisionShape: ->
    new Ammo.btSphereShape @parentItem.data.properties.radius
