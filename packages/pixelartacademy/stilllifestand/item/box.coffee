AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Box extends PAA.StillLifeStand.Item
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Box'
  @initialize()

  constructor: ->
    super arguments...

    @renderObject = new @constructor.RenderObject @
    @physicsObject = new @constructor.PhysicsObject @

  class @RenderObject extends PAA.StillLifeStand.Item.RenderObject
    createGeometry: ->
      size = @parentItem.data.properties.size
      new THREE.BoxBufferGeometry size.x, size.y, size.z

  class @PhysicsObject extends PAA.StillLifeStand.Item.PhysicsObject
    createCollisionShape: ->
      size = @parentItem.data.properties.size
      new Ammo.btBoxShape new Ammo.btVector3 size.x / 2, size.y / 2, size.z / 2
