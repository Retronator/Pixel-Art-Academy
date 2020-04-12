AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Sphere extends PAA.StillLifeStand.Item
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Sphere'
  @initialize()

  constructor: ->
    super arguments...

    @renderObject = new @constructor.RenderObject @
    @physicsObject = new @constructor.PhysicsObject @

  class @RenderObject extends PAA.StillLifeStand.Item.RenderObject
    createGeometry: ->
      new THREE.SphereBufferGeometry @parentItem.data.properties.radius, 32, 32

  class @PhysicsObject extends PAA.StillLifeStand.Item.PhysicsObject
    createCollisionShape: ->
      new Ammo.btSphereShape @parentItem.data.properties.radius
