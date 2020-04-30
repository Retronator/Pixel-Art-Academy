AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Sphere extends PAA.StillLifeStand.Item.ProceduralModel
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Sphere'
  @initialize()

  collisionShapeMargin: -> null

  createGeometry: ->
    new THREE.SphereBufferGeometry @parentItem.data.properties.radius, 32, 32

  createCollisionShape: ->
    new Ammo.btSphereShape @parentItem.data.properties.radius

  addDragObjects: ->
    radius = @parentItem.data.properties.radius
    area = Math.PI * radius ** 2
    dragCoefficient = 0.47
    dragFactor = area * dragCoefficient

    @addDragObject
      position: new THREE.Vector3()
      linearDragFactor: new THREE.Vector3 dragFactor, dragFactor, dragFactor
      angularDragFactor: new THREE.Vector3
