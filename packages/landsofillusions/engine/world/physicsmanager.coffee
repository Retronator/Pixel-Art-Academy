AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.Engine.World.PhysicsManager
  constructor: (@world) ->
    @collisionConfiguration = new Ammo.btDefaultCollisionConfiguration
    @dispatcher = new Ammo.btCollisionDispatcher @collisionConfiguration
    @overlappingPairCache = new Ammo.btDbvtBroadphase
    @solver = new Ammo.btSequentialImpulseConstraintSolver
    @dynamicsWorld = new Ammo.btDiscreteDynamicsWorld @dispatcher, @overlappingPairCache, @solver, @collisionConfiguration
    @dynamicsWorld.setGravity new Ammo.btVector3 0, -9.81, 0
    @bodies = []

    addBox = (halfSize, position) =>
      boxShape = new Ammo.btBoxShape halfSize
      boxLocalInertia = new Ammo.btVector3 0, 0, 0
    
      boxTransform = new Ammo.btTransform Ammo.btQuaternion.identity, position
      boxMotionState = new Ammo.btDefaultMotionState boxTransform
    
      boxInfo = new Ammo.btRigidBodyConstructionInfo 0, boxMotionState, boxShape, boxLocalInertia
      boxBody = new Ammo.btRigidBody boxInfo
    
      @dynamicsWorld.addRigidBody boxBody

    # Add ground.
    addBox new Ammo.btVector3(12, 1, 7.5), new Ammo.btVector3(0, -1, 0)

    # Add walls.
    addBox new Ammo.btVector3(12, 4, 1), new Ammo.btVector3(0, 2, 8.2)
    addBox new Ammo.btVector3(12, 4, 1), new Ammo.btVector3(0, 2, -8.5)
    addBox new Ammo.btVector3(1, 4, 7.5), new Ammo.btVector3(-13, 2, 0)
    addBox new Ammo.btVector3(1, 4, 7.5), new Ammo.btVector3(13, 2, 0)

    # Add insets.
    addBox new Ammo.btVector3(2, 4, 1.5), new Ammo.btVector3(0, 2, 6.5)
    addBox new Ammo.btVector3(2, 4, 1.5), new Ammo.btVector3(0, 2, -6.5)

    # Add scene items.
    @physicalAvatars = new AE.ReactiveArray =>
      # Get avatars of all things with a physics object.
      renderObjectsWithPhysics = @world.sceneManager().getAllChildren (item) => item.parentItem?.getPhysicsObject
      renderObjectWithPhysics.parentItem for renderObjectWithPhysics in renderObjectsWithPhysics
    ,
      added: (avatar) =>
        physicsObject = avatar.getPhysicsObject()
        @dynamicsWorld.addRigidBody physicsObject.body

      removed: (avatar) =>
        physicsObject = avatar.getPhysicsObject()
        @dynamicsWorld.removeRigidBody physicsObject.body
        physicsObject.destroy()

    # Create reusable objects.
    @_transform = new Ammo.btTransform

  update: (appTime) ->
    @dynamicsWorld.stepSimulation appTime.elapsedAppTime, 10

    for avatar in @physicalAvatars()
      # Update physical object.
      physicsObject = avatar.getPhysicsObject()
      physicsObject.update? appTime

      # Transfer transforms from physics to render objects.
      continue unless renderObject = avatar.getRenderObject()

      physicsObject = avatar.getPhysicsObject()
      physicsObject.motionState.getWorldTransform @_transform

      position = @_transform.getOrigin()
      renderObject.position.setFromBulletVector3 position

      rotation = @_transform.getRotation()
      renderObject.quaternion.setFromBulletQuaternion rotation

      # Transfer current angle when the physics object defines it.
      if physicsObject.currentAngle?
        renderObject.currentAngle = physicsObject.currentAngle

  destroy: ->
    @sceneItems.stop()

    Ammo.destroy dynamicsWorld
    Ammo.destroy solver
    Ammo.destroy overlappingPairCache
    Ammo.destroy dispatcher
    Ammo.destroy collisionConfiguration
