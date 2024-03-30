LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball
CollisionGroups = Pinball.PhysicsManager.CollisionGroups

class Pinball.Parts.SpinningTarget extends Pinball.Part
  # captive: boolean whether the spawned ball is captive
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.SpinningTarget'
  @fullName: -> "spinning target"
  @description: ->
    "
      A metal plate that spins when the ball hits its lower half.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/spinningtarget.png'
  
  @avatarShapes: -> [
    @Shape
  ]
  
  @initialize()
  
  settings: ->
    score:
      name: 'Score'
      type: Pinball.Interface.Settings.Number.id()
      
  constants: ->
    mass: 0.0002
    height: Pinball.CameraManager.orthographicPixelSize
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Metal
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: CollisionGroups.Actuators
    collisionMask: CollisionGroups.Balls

  extraShapeProperties: ->
    axisY: @pinball.sceneManager().ballYPosition() * 2 + Pinball.CameraManager.orthographicPixelSize * 1.5
    
  initialize: ->
    super arguments...
  
  onAddedToDynamicsWorld: (@_dynamicsWorld) ->
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
    physicsObject.body.setDamping 0, 0.75
    
    @defaultCollisionFlags = physicsObject.body.getCollisionFlags()
    physicsObject.body.setCollisionFlags @defaultCollisionFlags | Ammo.btCollisionObject.CollisionFlags.KinematicObject
    
    @_createConstraint()
  
  onRemovedFromDynamicsWorld: (dynamicsWorld) ->
    dynamicsWorld.removeConstraint @constraint
    @constraint = null
    
  onSimulationStarted: ->
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.body.setCollisionFlags @defaultCollisionFlags
    
  onSimulationEnded: ->
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.body.setCollisionFlags @defaultCollisionFlags | Ammo.btCollisionObject.CollisionFlags.KinematicObject
    
  reset: ->
    super arguments...
    
    # Recreate the constraint if needed.
    @_createConstraint() if @constraint
    
  _createConstraint: ->
    @_dynamicsWorld.removeConstraint @constraint if @constraint
    
    physicsObject = @avatar.getPhysicsObject()
    shape = @shape()
    
    axisY = shape.bitmapRectangle.center().y
    massY = shape.bitmapOrigin.y
    axisOffsetZ = (axisY - massY) * Pinball.CameraManager.orthographicPixelSize
    
    transform = new Ammo.btTransform Ammo.btQuaternion.identity(), new Ammo.btVector3 0, 0, axisOffsetZ
    @constraint = new Ammo.btGeneric6DofSpringConstraint physicsObject.body, transform, true
    
    @constraint.setLinearLowerLimit Ammo.btVector3.zero()
    @constraint.setLinearUpperLimit Ammo.btVector3.zero()
    
    @constraint.setAngularLowerLimit new Ammo.btVector3 -Math.PI, 0, 0
    @constraint.setAngularUpperLimit new Ammo.btVector3 Math.PI, 0, 0
    
    @_dynamicsWorld.addConstraint @constraint
    
  class @Shape extends Pinball.Part.Avatar.ConvexExtrusion
    _calculateBitmapOrigin: ->
      # Put all the weight at the bottom of the spinner.
      x: @bitmapRectangle.x() + @bitmapRectangle.width() * 0.5
      y: @bitmapRectangle.bottom() - 0.5
      
    yPosition: -> @properties.axisY
    
    collisionShapeMargin: -> @height / 2
    
    positionSnapping: -> false
    
    rotationStyle: -> @constructor.RotationStyles.Free
  
    meshStyle: -> @constructor.MeshStyles.Extrusion
