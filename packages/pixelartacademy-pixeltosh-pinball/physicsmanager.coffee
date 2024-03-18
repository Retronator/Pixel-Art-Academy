AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

if Meteor.isClient
  _transform = new Ammo.btTransform

class Pinball.PhysicsManager
  @BallConstants =
    Restitution: 0.6
    Friction: 1
    RollingFriction: 0
  
  @RestitutionConstants =
    HardSurface: 0.6 / @BallConstants.Restitution # steel ball bearing on concrete, golf ball on wood
  
  @FrictionConstants =
    Wood: 0.4 / @BallConstants.Friction # steel-wood (0.2–0.6)
    Plastic: 0.2 / @BallConstants.Friction # plastic-metal (0.1–0.3)
  
  @RollingFrictionConstants =
    Coarse: 0.02 # 1-inch steel bearing on P80 emery paper (0.01–0.02)
    Smooth: 0.01 # 1-inch steel bearing on P80 emery paper (0.005–0.01)
  
  @CollisionGroups =
    Balls: 1
    BallGuides: 2
    Actuators: 4
  
  @simulationTimestep = 1 / 300
  @maxSimulationStepsPerFrame = 0.1 / @simulationTimestep
  @continuousCollisionDetectionThreshold = 1e-7
  
  constructor: (@pinball) ->
    @collisionConfiguration = new Ammo.btDefaultCollisionConfiguration
    @dispatcher = new Ammo.btCollisionDispatcher @collisionConfiguration
    @overlappingPairCache = new Ammo.btDbvtBroadphase
    @solver = new Ammo.btSequentialImpulseConstraintSolver
    @dynamicsWorld = new Ammo.btDiscreteDynamicsWorld @dispatcher, @overlappingPairCache, @solver, @collisionConfiguration
    
    gravity = new Ammo.btVector3 0, -9.81, 0
    gravity = gravity.rotate new Ammo.btVector3(1, 0, 0), -Pinball.SceneManager.shortPlayfieldPitchDegrees / 180 * Math.PI
    @dynamicsWorld.setGravity gravity

    # Add ground of wooden material.
    @ground = new Ammo.btRigidBody new Ammo.btRigidBodyConstructionInfo 0,
      new Ammo.btDefaultMotionState new Ammo.btTransform Ammo.btQuaternion.identity(), new Ammo.btVector3(0, -1, 0)
    ,
      new Ammo.btBoxShape new Ammo.btVector3(10, 1, 10), 0

    # We set coefficients for the ground (wood) colliding with the ball (steel bearing).
    @ground.setRestitution @constructor.RestitutionConstants.HardSurface
    @ground.setFriction @constructor.FrictionConstants.Wood
    @ground.setRollingFriction @constructor.RollingFrictionConstants.Coarse

    @dynamicsWorld.addRigidBody @ground
    
    # Add safety walls.
    @dynamicsWorld.addRigidBody new Ammo.btRigidBody new Ammo.btRigidBodyConstructionInfo 0,
      new Ammo.btDefaultMotionState new Ammo.btTransform Ammo.btQuaternion.identity(), new Ammo.btVector3(-1, 0, 0)
    ,
      new Ammo.btBoxShape new Ammo.btVector3(1, 10, 10), 0
    
    @dynamicsWorld.addRigidBody new Ammo.btRigidBody new Ammo.btRigidBodyConstructionInfo 0,
      new Ammo.btDefaultMotionState new Ammo.btTransform Ammo.btQuaternion.identity(), new Ammo.btVector3(Pinball.SceneManager.playfieldWidth + 1, 0, 0)
    ,
      new Ammo.btBoxShape new Ammo.btVector3(1, 10, 10), 0
    
    @dynamicsWorld.addRigidBody new Ammo.btRigidBody new Ammo.btRigidBodyConstructionInfo 0,
      new Ammo.btDefaultMotionState new Ammo.btTransform Ammo.btQuaternion.identity(), new Ammo.btVector3(0, 0, -1)
    ,
      new Ammo.btBoxShape new Ammo.btVector3(10, 10, 1), 0
    
    @dynamicsWorld.addRigidBody new Ammo.btRigidBody new Ammo.btRigidBodyConstructionInfo 0,
      new Ammo.btDefaultMotionState new Ammo.btTransform Ammo.btQuaternion.identity(), new Ammo.btVector3(0, 0, Pinball.SceneManager.shortPlayfieldHeight + 1)
    ,
      new Ammo.btBoxShape new Ammo.btVector3(10, 10, 1), 0
    
    # Add playfield parts.
    @partPhysicsObjects = new AE.ReactiveArray =>
      physicsObject for part in @pinball.sceneManager()?.parts() when physicsObject = part.avatar.getPhysicsObject()
    ,
      added: (physicsObject) =>
        # Add the part to the simulation.
        @dynamicsWorld.addRigidBody physicsObject.body, physicsObject.avatar.properties.collisionGroup, physicsObject.avatar.properties.collisionMask
        physicsObject.avatar.part.onAddedToDynamicsWorld @dynamicsWorld

      removed: (physicsObject) =>
        @dynamicsWorld.removeRigidBody physicsObject.body
        physicsObject.avatar.part.onRemovedFromDynamicsWorld @dynamicsWorld

  destroy: ->
    @partPhysicsObjects.stop()

    Ammo.destroy @dynamicsWorld
    Ammo.destroy @solver
    Ammo.destroy @overlappingPairCache
    Ammo.destroy @dispatcher
    Ammo.destroy @collisionConfiguration

  update: (appTime) ->
    return unless appTime.elapsedAppTime
    
    stepCount = Math.min @constructor.maxSimulationStepsPerFrame, Math.ceil appTime.elapsedAppTime / @constructor.simulationTimestep

    for step in [0...stepCount]
      @dynamicsWorld.stepSimulation @constructor.simulationTimestep, 1, @constructor.simulationTimestep
      @pinball.fixedUpdate @constructor.simulationTimestep
    
    quantizePosition = @pinball.cameraManager().displayType() is Pinball.CameraManager.DisplayTypes.Orthographic and not @pinball.debugPhysics()
    quantizePositionAmount = if quantizePosition then Pinball.CameraManager.orthographicPixelSize else 0

    @_updateRenderObject physicsObject, quantizePositionAmount for physicsObject in @partPhysicsObjects()

  _updateRenderObject: (physicsObject, quantizePositionAmount) ->
    # Transfer transforms from physics to render objects.
    renderObject = physicsObject.avatar.getRenderObject()

    physicsObject.motionState.getWorldTransform _transform
    renderObject.updateFromPhysics _transform, quantizePositionAmount
