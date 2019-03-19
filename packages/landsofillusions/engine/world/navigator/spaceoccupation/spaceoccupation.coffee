AE = Artificial.Everywhere
AS = Artificial.Spectrum
AR = Artificial.Reality
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Engine.World.Navigator.SpaceOccupation
  constructor: (@navigator) ->
    @collisionConfiguration = new Ammo.btDefaultCollisionConfiguration
    @dispatcher = new Ammo.btCollisionDispatcher @collisionConfiguration
    @overlappingPairCache = new Ammo.btDbvtBroadphase
    @solver = new Ammo.btSequentialImpulseConstraintSolver
    @dynamicsWorld = new Ammo.btDiscreteDynamicsWorld @dispatcher, @overlappingPairCache, @solver, @collisionConfiguration
    @dynamicsWorld.setGravity new Ammo.btVector3 0, -9.81, 0

    @placeholders = []
    @_placeholdersUpdated = new Tracker.Dependency

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
      @navigator.world.sceneManager().physicalItems()
    ,
      added: (item) =>
        # Create a same-shaped placeholder that will be positioned at item's target position.
        placeholder = new @constructor.Placeholder item
        @placeholders.push placeholder

        @dynamicsWorld.addRigidBody placeholder.body
        @_placeholdersUpdated.changed()

      removed: (item) =>
        placeholder = _.find @placeholders, (placeholder) => placeholder.sourceItem is item
        @dynamicsWorld.removeRigidBody placeholder.body
        physicsObject.destroy()

        _.pull @placeholders, placeholder
        @_placeholdersUpdated.changed()

    # Add debug objects.
    @debugObjects = []

    @navigator.world.autorun (computation) =>
      return unless @navigator.world.spaceOccupationDebug()
      @_placeholdersUpdated.depend()

      return unless scene = @navigator.world.sceneManager().scene()

      for placeholder in @placeholders
        debugObject = _.find @debugObjects, (debugObject) => debugObject.placeholder is placeholder
          
        if debugObject
          # Debug object is still valid, just update its position.
          debugObject.position.copy placeholder.getPosition()
          debugObject.quaternion.copy placeholder.getRotation()

        else
          # Debug object needs to be created.
          debugObject = placeholder.createDebugObject()
          scene.add debugObject
          @debugObjects.push debugObject

      for debugObject in @debugObjects when debugObject.placeholder not in @placeholders
        scene.remove debugObject
        _.pull @debugObjects, debugObject
        
  debugUpdate: (appTime) ->
    @dynamicsWorld.stepSimulation appTime.elapsedAppTime
    @_placeholdersUpdated.changed()

  findEmptySpace: (item, position) ->
    itemFound = false
    itemPlaceholder = null

    for physicalItem in @physicalItems()
      placeholder = _.find @placeholders, (placeholder) => placeholder.sourceItem is physicalItem

      if physicalItem is item
        itemFound = true
        itemPlaceholder = placeholder

      else
        # Change the placeholder into a static rigid body and set its current position.
        placeholder.setMass 0
        physicsObject = physicalItem.getPhysicsObject()
        placeholder.setPosition physicsObject.targetPosition or physicsObject.getPosition()
        placeholder.setRotation physicsObject.getRotation() unless physicsObject.hasFixedRotation

    unless itemFound
      # Create a temporary placeholder for the item.
      itemPlaceholder = new @constructor.Placeholder item
      @dynamicsWorld.addRigidBody itemPlaceholder.body

    # Make the item placeholder a dynamic object.
    itemPlaceholder.setMass 1

    # Position the item placeholder to the desired position.
    itemPlaceholder.setPosition position

    # Update the simulation so that placeholder gets moved to a valid position.
    relaxationFramesCount = 10
    @dynamicsWorld.stepSimulation 1, relaxationFramesCount, 1 / relaxationFramesCount

    unless itemFound
      # Remove the temporary placeholder.
      @dynamicsWorld.removeRigidBody itemPlaceholder.body

    @_placeholdersUpdated.changed()

    # Return the relaxed position of the placeholder.
    itemPlaceholder.getPosition()
