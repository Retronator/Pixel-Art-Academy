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

      materialOptions =
        palette: LOI.palette()
        ramp: 0
        shade: 8
        dither: 0
        smoothShading: false

      material = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.RampMaterial.id(), materialOptions
      depthMaterial = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.DepthMaterial.id()
      shadowColorMaterial = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.ShadowColorMaterial.id(), materialOptions
      preprocessingMaterial = LOI.Engine.Materials.getMaterial LOI.Engine.Materials.PreprocessingMaterial.id(), materialOptions

      geometry = @parentItem.createGeometry()
      mesh = new THREE.Mesh geometry, material
      mesh.castShadow = true
      mesh.receiveShadow = true

      mesh.mainMaterial = material
      mesh.shadowColorMaterial = shadowColorMaterial
      mesh.customDepthMaterial = depthMaterial
      mesh.preprocessingMaterial = preprocessingMaterial

      @add mesh

      @position.copy @parentItem.position

  class @PhysicsObject extends AR.PhysicsObject
    constructor: (@parentItem) ->
      super arguments...

      @mass = 1
      @localInertia = new Ammo.btVector3 0, 0, 0

      @collisionShape = @createCollisionShape()
      @collisionShape.calculateLocalInertia @mass, @localInertia

      transform = new Ammo.btTransform Ammo.btQuaternion.identity(), @parentItem.position.toBulletVector3()
      @motionState = new Ammo.btDefaultMotionState transform

      rigidBodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
      @body = new Ammo.btRigidBody rigidBodyInfo

    createCollisionShape: (options) ->
      @parentItem.createCollisionShape options

    createDebugObject: (options) ->
      options = _.extend {}, options,
        debug: true

      new THREE.Mesh @parentItem.createGeometry(options), options.material

class LOI.Engine.Debug.DummySceneItem.Ball extends LOI.Engine.Debug.DummySceneItem
  constructor: (@position, @radius) ->
    super arguments...
    @initialize()

  createGeometry: (options = {}) ->
    segments = if options.debug then 8 else 32
    radius = @radius + (options.occupationMargin or 0) + (options.extrude or 0)
    new THREE.SphereGeometry radius, segments, segments

  createCollisionShape: (options = {}) ->
    radius = @radius + (options.occupationMargin or 0)
    new Ammo.btSphereShape radius

class LOI.Engine.Debug.DummySceneItem.Box extends LOI.Engine.Debug.DummySceneItem
  constructor: (@position, @halfSize) ->
    super arguments...
    @initialize()

  createGeometry: (options = {}) ->
    size = (@halfSize + (options.occupationMargin or 0) + (options.extrude or 0)) * 2
    new THREE.BoxGeometry size, size, size

  createCollisionShape: (options = {}) ->
    halfSize = @halfSize + (options.occupationMargin or 0)
    new Ammo.btBoxShape new Ammo.btVector3(halfSize, halfSize, halfSize)
