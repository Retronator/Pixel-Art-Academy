LOI = LandsOfIllusions
AS = Artificial.Spectrum
AR = Artificial.Reality

class LOI.Engine.Debug.DummySceneItem
  constructor: (@position) ->
    @position.y = 1

  initialize: ->
    @renderObject = new @constructor.RenderObject @
    @physicsObject = new @constructor.PhysicsObject @

  getRenderObject: -> @renderObject
  getPhysicsObject: -> @physicsObject

  class @RenderObject extends AS.RenderObject
    constructor: (@parentItem) ->
      super arguments...

      material = new LOI.Engine.Materials.RampMaterial
        shades: LOI.palette().ramps[0].shades
        shadeIndex: 8

      geometry = @parentItem.createGeometry()
      mesh = new THREE.Mesh geometry, material
      mesh.castShadow = true
      mesh.receiveShadow = true

      @add mesh

      @position.copy @parentItem.position

  class @PhysicsObject extends AR.PhysicsObject
    constructor: (@parentItem) ->
      super arguments...

      @mass = 1
      @localInertia = new Ammo.btVector3 0, 0, 0

      @collisionShape = @parentItem.createCollisionShape()
      @collisionShape.calculateLocalInertia @mass, @localInertia

      transform = new Ammo.btTransform Ammo.btQuaternion.identity, @parentItem.position.toBulletVector3()
      @motionState = new Ammo.btDefaultMotionState transform

      rigidBodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
      @body = new Ammo.btRigidBody rigidBodyInfo

class LOI.Engine.Debug.DummySceneItem.Ball extends LOI.Engine.Debug.DummySceneItem
  constructor: (@position, @radius) ->
    super arguments...
    @initialize()

  createGeometry: ->
    new THREE.SphereBufferGeometry @radius, 32, 32

  createCollisionShape: ->
    new Ammo.btSphereShape @radius

class LOI.Engine.Debug.DummySceneItem.Box extends LOI.Engine.Debug.DummySceneItem
  constructor: (@position, @halfSize) ->
    super arguments...
    @initialize()

  createGeometry: ->
    size = @halfSize * 2
    new THREE.BoxBufferGeometry size, size, size

  createCollisionShape: ->
    new Ammo.btBoxShape new Ammo.btVector3(@halfSize, @halfSize, @halfSize)
