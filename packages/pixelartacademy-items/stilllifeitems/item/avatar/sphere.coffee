AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Items.StillLifeItems.Item.Avatar.Sphere extends PAA.Items.StillLifeItems.Item.Avatar.ProceduralModel
  @initializeEngineObjectClasses()

  collisionShapeMargin: -> null

  createGeometry: ->
    new THREE.SphereGeometry @avatar.properties.radius, 32, 32

  createCollisionShape: ->
    new Ammo.btSphereShape @avatar.properties.radius

  addDragObjects: ->
    radius = @avatar.properties.radius
    area = Math.PI * radius ** 2
    dragCoefficient = 0.47
    dragFactor = area * dragCoefficient

    @addDragObject
      position: new THREE.Vector3()
      linearDragFactor: new THREE.Vector3 dragFactor, dragFactor, dragFactor
      angularDragFactor: new THREE.Vector3
