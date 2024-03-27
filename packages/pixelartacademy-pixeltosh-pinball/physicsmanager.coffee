AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

if Meteor.isClient
  _rayOrigin = new Ammo.btVector3
  _rayDestination = new Ammo.btVector3
  _closestRayResultCallback = new Ammo.ClosestRayResultCallback _rayOrigin, _rayDestination

class Pinball.PhysicsManager
  @BallConstants =
    Restitution: 0.6
    Friction: 1
    RollingFriction: 0
  
  @RestitutionConstants =
    Rubber: 0.9 / @BallConstants.Restitution
    HardSurface: 0.6 / @BallConstants.Restitution # steel ball bearing on concrete, golf ball on wood
  
  @FrictionConstants =
    Rubber: 0.9
    Wood: 0.4 / @BallConstants.Friction # steel-wood (0.2–0.6)
    Plastic: 0.2 / @BallConstants.Friction # plastic-metal (0.1–0.3)
    Metal: 0.3 / @BallConstants.Friction # steel-steel (0.1–0.5)
  
  @RollingFrictionConstants =
    Rubber: 0.05
    Coarse: 0.02 # 1-inch steel bearing on P80 emery paper (0.01–0.02)
    Smooth: 0.01 # 1-inch steel bearing on P80 emery paper (0.005–0.01)
  
  @CollisionGroups =
    Balls: 1
    BallGuides: 2
    Actuators: 4
  
  @simulationTimestep = 1 / 1000
  @maxSimulationStepsPerFrame = 0.1 / @simulationTimestep
  @continuousCollisionDetectionThreshold = 1e-7
  
  constructor: (@pinball) ->
    @collisionConfiguration = new Ammo.btDefaultCollisionConfiguration
    @dispatcher = new Ammo.btCollisionDispatcher @collisionConfiguration
    @broadphase = new Ammo.btDbvtBroadphase
    @solver = new Ammo.btSequentialImpulseConstraintSolver
    @dynamicsWorld = new Ammo.btDiscreteDynamicsWorld @dispatcher, @broadphase, @solver, @collisionConfiguration
    
    gravity = new Ammo.btVector3 0, -9.81, 0
    gravity = gravity.rotate new Ammo.btVector3(1, 0, 0), -Pinball.SceneManager.shortPlayfieldPitchDegrees / 180 * Math.PI
    @dynamicsWorld.setGravity gravity
    
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
    @physicsObjects = new AE.ReactiveArray =>
      physicsObject for entity in @pinball.sceneManager()?.entities() when physicsObject = entity.getPhysicsObject()
    ,
      added: (physicsObject) =>
        # Add the part to the simulation.
        constants = physicsObject.entity.constants()
        @dynamicsWorld.addRigidBody physicsObject.body, constants.collisionGroup, constants.collisionMask
        physicsObject.entity.onAddedToDynamicsWorld? @dynamicsWorld

      removed: (physicsObject) =>
        @dynamicsWorld.removeRigidBody physicsObject.body
        physicsObject.entity.onRemovedFromDynamicsWorld? @dynamicsWorld

  destroy: ->
    @physicsObjects.stop()

    Ammo.destroy @dynamicsWorld
    Ammo.destroy @solver
    Ammo.destroy @broadphase
    Ammo.destroy @dispatcher
    Ammo.destroy @collisionConfiguration
  
  intersectObject: (start, end) ->
    rayCallback = Ammo.castObject _closestRayResultCallback, Ammo.RayResultCallback
    rayCallback.set_m_closestHitFraction 1
    rayCallback.set_m_collisionObject null
    
    _rayOrigin.copy start
    _rayDestination.copy end
    
    _closestRayResultCallback.get_m_rayFromWorld().setValue start.x, start.y, start.z
    _closestRayResultCallback.get_m_rayToWorld().setValue end.x, end.y, end.z
    
    @dynamicsWorld.rayTest _rayOrigin, _rayDestination, _closestRayResultCallback
    
    return unless _closestRayResultCallback.hasHit()
    
    rigidBody = Ammo.castObject _closestRayResultCallback.m_collisionObject, Ammo.btRigidBody
    rigidBody.physicsObject?.entity
    
  update: (appTime) ->
    return unless appTime.elapsedAppTime
    
    stepCount = Math.min @constructor.maxSimulationStepsPerFrame, Math.ceil appTime.elapsedAppTime / @constructor.simulationTimestep
    
    if @pinball.slowMotion()
      stepCount = Math.ceil stepCount / 100

    for step in [0...stepCount]
      @dynamicsWorld.stepSimulation @constructor.simulationTimestep, 1, @constructor.simulationTimestep
      @pinball.fixedUpdate @constructor.simulationTimestep
      
    for physicsObject in @physicsObjects()
      renderObject = physicsObject.entity.getRenderObject()
      renderObject.updateFromPhysicsObject physicsObject
