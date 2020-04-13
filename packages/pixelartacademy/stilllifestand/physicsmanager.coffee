AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

_transform = new Ammo.btTransform

class PAA.StillLifeStand.PhysicsManager
  constructor: (@stillLifeStand) ->
    @collisionConfiguration = new Ammo.btDefaultCollisionConfiguration
    @dispatcher = new Ammo.btCollisionDispatcher @collisionConfiguration
    @overlappingPairCache = new Ammo.btDbvtBroadphase
    @solver = new Ammo.btSequentialImpulseConstraintSolver
    @dynamicsWorld = new Ammo.btDiscreteDynamicsWorld @dispatcher, @overlappingPairCache, @solver, @collisionConfiguration
    @dynamicsWorld.setGravity new Ammo.btVector3 0, -9.81, 0

    # Add ground.
    @dynamicsWorld.addRigidBody new Ammo.btRigidBody new Ammo.btRigidBodyConstructionInfo 0,
      new Ammo.btDefaultMotionState new Ammo.btTransform Ammo.btQuaternion.identity, new Ammo.btVector3
    ,
      new Ammo.btStaticPlaneShape new Ammo.btVector3(0, 1, 0), 0

    # Add cursor.
    @cursor = new @constructor.Cursor
    @dynamicsWorld.addRigidBody @cursor.body

    # Add scene items.
    @items = new AE.ReactiveArray =>
      @stillLifeStand.sceneManager()?.items()
    ,
      added: (item) =>
        @dynamicsWorld.addRigidBody item.physicsObject.body

      removed: (item) =>
        @dynamicsWorld.removeRigidBody item.physicsObject.body

  update: (appTime) ->
    return unless appTime.elapsedAppTime

    @dynamicsWorld.stepSimulation appTime.elapsedAppTime, 10

    for item in @items()
      # Transfer transforms from physics to render objects.
      item.physicsObject.motionState.getWorldTransform _transform

      item.renderObject.position.setFromBulletVector3 _transform.getOrigin()
      item.renderObject.quaternion.setFromBulletQuaternion _transform.getRotation()

  destroy: ->
    @items.stop()

    Ammo.destroy @dynamicsWorld
    Ammo.destroy @solver
    Ammo.destroy @overlappingPairCache
    Ammo.destroy @dispatcher
    Ammo.destroy @collisionConfiguration

  class @Cursor extends AR.PhysicsObject
    constructor: ->
      super arguments...

      @mass = 0
      @motionState = new Ammo.btDefaultMotionState new Ammo.btTransform Ammo.btQuaternion.identity, new Ammo.btVector3
      @collisionShape = new Ammo.btSphereShape 0

      @body = new Ammo.btRigidBody new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape

      # Mark as kinematic object and disable deactivation so we can manually move the cursor by direct positioning.
      @body.setCollisionFlags Ammo.btCollisionObject.CollisionFlags.KinematicObject
      @body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
