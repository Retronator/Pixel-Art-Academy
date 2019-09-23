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
    @physicalItems = new AE.ReactiveArray =>
      # Get all items with a physics object.
      @world.sceneManager().physicalItems()
    ,
      added: (item) =>
        physicsObject = item.getPhysicsObject()
        @dynamicsWorld.addRigidBody physicsObject.body

      removed: (item) =>
        physicsObject = item.getPhysicsObject()
        @dynamicsWorld.removeRigidBody physicsObject.body
        physicsObject.destroy()

    # Add debug objects.
    @debugObjects = []

    @world.autorun (computation) =>
      return unless @world.physicsDebug()
      return unless scene = @world.sceneManager().scene()

      # Initialize debug material.
      @constructor.debugMaterial ?= new THREE.MeshLambertMaterial
        wireframe: true
        color: new THREE.Color 0x00ff00

      physicalItems = @physicalItems()

      # Create debug objects for new items.
      for item in physicalItems
        continue if _.find @debugObjects, (debugObject) => debugObject.item is item

        # Debug object needs to be created.
        physicsObject = item.getPhysicsObject()

        debugObject = physicsObject.createDebugObject
          material: @constructor.debugMaterial
          extrude: 0.05

        debugObject.item = item

        for debugObjectPart in debugObject.getAllObjectsInSubtree()
          debugObjectPart.layers.set LOI.Engine.World.RendererManager.RenderLayers.PhysicsDebug

        scene.add debugObject
        @debugObjects.push debugObject

      # Remove debug objects for removed items.
      removed = false

      for debugObject, index in @debugObjects when debugObject.item not in physicalItems
        scene.remove debugObject
        @debugObjects[index] = null
        removed = true

      _.pull @debugObjects, null if removed

    # Create reusable objects.
    @_transform = new Ammo.btTransform

  update: (appTime) ->
    @dynamicsWorld.stepSimulation appTime.elapsedAppTime, 10

    for item in @physicalItems()
      # Update physical object.
      physicsObject = item.getPhysicsObject()
      physicsObject.update? appTime

      # Transfer transforms from physics to render objects.
      continue unless renderObject = item.getRenderObject()

      physicsObject = item.getPhysicsObject()
      physicsObject.motionState.getWorldTransform @_transform

      position = @_transform.getOrigin()
      renderObject.position.setFromBulletVector3 position

      rotation = @_transform.getRotation()
      renderObject.quaternion.setFromBulletQuaternion rotation

      if @world.physicsDebug()
        # Update debug object.
        continue unless debugObject = _.find @debugObjects, (debugObject) => debugObject.item is item
        debugObject.position.copy renderObject.position
        debugObject.quaternion.copy renderObject.quaternion

  destroy: ->
    @sceneItems.stop()

    Ammo.destroy dynamicsWorld
    Ammo.destroy solver
    Ammo.destroy overlappingPairCache
    Ammo.destroy dispatcher
    Ammo.destroy collisionConfiguration
