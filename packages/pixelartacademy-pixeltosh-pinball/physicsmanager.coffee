AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

if Meteor.isClient
  _transform = new Ammo.btTransform

class Pinball.PhysicsManager
  constructor: (@pinball) ->
    @collisionConfiguration = new Ammo.btDefaultCollisionConfiguration
    @dispatcher = new Ammo.btCollisionDispatcher @collisionConfiguration
    @overlappingPairCache = new Ammo.btDbvtBroadphase
    @solver = new Ammo.btSequentialImpulseConstraintSolver
    @dynamicsWorld = new Ammo.btDiscreteDynamicsWorld @dispatcher, @overlappingPairCache, @solver, @collisionConfiguration
    
    gravity = new Ammo.btVector3 0, -9.81, 0
    gravity = gravity.rotate new Ammo.btVector3(1, 0, 0), -Pinball.SceneManager.shortPlayfieldPitchDegrees / 180 * Math.PI
    @dynamicsWorld.setGravity gravity

    @simulationTimestep = 1 / 300
    @maxSimulationStepsPerFrame = 0.1 / @simulationTimestep

    # Adjust constants for improved stability.
    @linearDamping = 0.0001
    @angularDamping = 0.0001
    @linearSleepingThreshold = 1
    @angularSleepingThreshold = 1
    @contactProcessingThreshold = 0.01

    @surroundingGasDensity = 1.225 # Kg / m³

    @minSpeedSquaredToApplyDrag = 1e-3

    @_previousCursorPosition = new THREE.Vector3

    # Add ground of wooden material.
    @ground = new Ammo.btRigidBody new Ammo.btRigidBodyConstructionInfo 0,
      new Ammo.btDefaultMotionState new Ammo.btTransform Ammo.btQuaternion.identity, new Ammo.btVector3(0, -0.5, 0)
    ,
      new Ammo.btBoxShape new Ammo.btVector3(10, 0.5, 10), 0

    @ground.setRestitution 0.6
    @ground.setFriction 0.7
    @ground.setRollingFriction 0.05

    @dynamicsWorld.addRigidBody @ground

    # Add playfield parts.
    @parts = new AE.ReactiveArray =>
      @pinball.sceneManager()?.parts()
    ,
      added: (part) =>
        physicsObject = part.avatar.getPhysicsObject()

        # Set constants for improved stability.
        physicsObject.body.setDamping @linearDamping, @angularDamping
        physicsObject.body.setSleepingThresholds @linearSleepingThreshold, @angularSleepingThreshold
        physicsObject.body.setContactProcessingThreshold @contactProcessingThreshold

        # Add the part to the simulation.
        @dynamicsWorld.addRigidBody physicsObject.body

      removed: (part) =>
        physicsObject = part.avatar.getPhysicsObject()
        @dynamicsWorld.removeRigidBody physicsObject.body

  destroy: ->
    @parts.stop()

    Ammo.destroy @dynamicsWorld
    Ammo.destroy @solver
    Ammo.destroy @overlappingPairCache
    Ammo.destroy @dispatcher
    Ammo.destroy @collisionConfiguration

  update: (appTime) ->
    return unless appTime.elapsedAppTime

    @dynamicsWorld.stepSimulation appTime.elapsedAppTime, @maxSimulationStepsPerFrame, @simulationTimestep

    @_updatePart part for part in @parts()

  _updatePart: (part) ->
    renderObject = part.avatar.getRenderObject()
    physicsObject = part.avatar.getPhysicsObject()

    # Transfer transforms from physics to render objects.
    physicsObject.motionState.getWorldTransform _transform

    renderObject.position.setFromBulletVector3 _transform.getOrigin()
    renderObject.quaternion.setFromBulletQuaternion _transform.getRotation()
