AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item.Cone extends PAA.StillLifeStand.Item
  @id: -> 'PixelArtAcademy.StillLifeStand.Item.Cone'
  @initialize()

  constructor: ->
    super arguments...

    @renderObject = new @constructor.RenderObject @
    @physicsObject = new @constructor.PhysicsObject @

  class @RenderObject extends PAA.StillLifeStand.Item.RenderObject
    createGeometry: ->
      properties = @parentItem.data.properties
      new THREE.ConeBufferGeometry properties.radius, properties.height, 32, 32

  class @PhysicsObject extends PAA.StillLifeStand.Item.PhysicsObject
    createCollisionShape: ->
      properties = @parentItem.data.properties
      margin = PAA.StillLifeStand.Item.roughEdgeMargin

      collisionShape = new Ammo.btConeShape properties.radius - 2 * margin, properties.height - 2 * margin
      collisionShape
