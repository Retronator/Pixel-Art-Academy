AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Item
  @_itemClassesById = {}

  @getClassForId: (id) ->
    @_itemClassesById[id]

  @id: -> throw new AE.NotImplementedException "You must specify still life item's id."

  @initialize: ->
    # Store item class by ID.
    @_itemClassesById[@id()] = @

  constructor: (@data) ->

  destroy: ->
    @renderObject.destroy()
    @physicsObject.destroy()

  class @RenderObject extends AS.RenderObject
    constructor: (@parentItem) ->
      super arguments...

      @material = new THREE.MeshStandardMaterial
      @geometry = @createGeometry()

      @mesh = new THREE.Mesh @geometry, @material

      @add @mesh

    createGeometry: ->
      throw new AE.NotImplementedException "Still life item render object must provide a geometry."

  class @PhysicsObject extends AR.PhysicsObject
    constructor: (@parentItem) ->
      super arguments...

      positionData = @parentItem.data.position or x: 0, y: 0, z: 0
      position = Ammo.btVector3.fromObject positionData

      rotationQuaternionData = @parentItem.data.rotationQuaternion or x: 0, y: 0, z: 0, w: 0
      rotationQuaternion = Ammo.btQuaternion.fromObject rotationQuaternionData

      transform = new Ammo.btTransform rotationQuaternion, position
      @motionState = new Ammo.btDefaultMotionState transform

      @mass = @parentItem.data.properties.mass ? 1
      @localInertia = new Ammo.btVector3 0, 0, 0
      @collisionShape = @createCollisionShape()
      @collisionShape.calculateLocalInertia @mass, @localInertia

      bodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
      @body = new Ammo.btRigidBody bodyInfo
      @body.setRestitution 1

    createCollisionShape: ->
      throw new AE.NotImplementedException "Still life item physics object must provide a collision shape."