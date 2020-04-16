AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Cylinder extends PAA.StillLifeStand.Item
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Cylinder'
  @initialize()

  constructor: ->
    super arguments...

    @renderObject = new @constructor.RenderObject @
    @physicsObject = new @constructor.PhysicsObject @

  class @RenderObject extends PAA.StillLifeStand.Item.RenderObject
    createGeometry: ->
      properties = @parentItem.data.properties
      new THREE.CylinderBufferGeometry properties.radius, properties.radius, properties.height, 32

  class @PhysicsObject extends PAA.StillLifeStand.Item.PhysicsObject
    createCollisionShape: ->
      properties = @parentItem.data.properties
      new Ammo.btCylinderShape new Ammo.btVector3 properties.radius, properties.height / 2, properties.radius
