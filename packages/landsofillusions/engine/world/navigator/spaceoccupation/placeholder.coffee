AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.Engine.World.Navigator.SpaceOccupation.Placeholder extends AR.PhysicsObject
  constructor: (@sourceItem) ->
    super arguments...

    @sourcePhysicsObject = @sourceItem.getPhysicsObject()

    @mass = 1
    @motionState = new Ammo.btDefaultMotionState
    @localInertia = new Ammo.btVector3 0, 0, 0

    @occupationMargin = 0.2
    @collisionShape = @sourcePhysicsObject.createCollisionShape
      occupationMargin: @occupationMargin

    @collisionShape.calculateLocalInertia @mass, @localInertia

    @rigidBodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia

    @body = new Ammo.btRigidBody @rigidBodyInfo
    @body.setAngularFactor 0 if @sourcePhysicsObject.hasFixedRotation

    # Disable deactivation so we can manually move the body by direct positioning.
    @body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation

  createDebugObject: ->
    # Initialize debug material.
    @constructor.debugMaterial ?= new THREE.MeshLambertMaterial
      wireframe: true
      color: new THREE.Color 0xffff00
      
    debugObject = @sourcePhysicsObject.createDebugObject
      material: @constructor.debugMaterial
      occupationMargin: @occupationMargin

    debugObject.position.copy @getPosition()
    debugObject.placeholder = @

    for debugObjectPart in debugObject.getAllObjectsInSubtree()
      debugObjectPart.layers.set LOI.Engine.World.RendererManager.RenderLayers.SpaceOccupationDebug

    debugObject
