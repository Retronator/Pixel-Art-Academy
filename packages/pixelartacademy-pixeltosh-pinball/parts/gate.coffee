LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball
CollisionGroups = Pinball.PhysicsManager.CollisionGroups

class Pinball.Parts.Gate extends Pinball.Parts.DynamicPart
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Gate'
  @fullName: -> "gate"
  @description: ->
    "
      A rotating piece that lets the ball go through in only one direction.
    "
    
  @assetId: -> Pinball.Assets.Gate.id()
  
  @avatarShapes: -> [
    @Shape
  ]
  
  @initialize()
  
  @placeableRequiredTask: -> LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.DrawGate
  
  constants: ->
    mass: 0.0001
    height: 0.001
    meshHeight: Pinball.CameraManager.orthographicPixelSize * 2
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Metal
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: CollisionGroups.Actuators
    collisionMask: CollisionGroups.Balls

  extraShapeProperties: ->
    return unless sceneManager = @pinball.sceneManager()
    
    axisY: sceneManager.ballPositionY() * 2.5
    
  onAddedToDynamicsWorld: (@_dynamicsWorld) ->
    super arguments...
    
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.body.setDamping 0, 0.75
    
    @_createConstraint()
  
  onRemovedFromDynamicsWorld: (dynamicsWorld) ->
    dynamicsWorld.removeConstraint @constraint
    @constraint = null

  reset: ->
    super arguments...
    
    # Recreate the constraint if needed.
    @_createConstraint() if @constraint
    
  _createConstraint: ->
    @_dynamicsWorld.removeConstraint @constraint if @constraint
    
    physicsObject = @avatar.getPhysicsObject()
    shape = @shape()
    
    axisY = shape.bitmapRectangle.top() + 1
    massY = shape.bitmapOrigin.y
    axisOffsetZ = (axisY - massY) * Pinball.CameraManager.orthographicPixelSize
    
    transform = new Ammo.btTransform Ammo.btQuaternion.identity(), new Ammo.btVector3 0, 0, axisOffsetZ
    @constraint = new Ammo.btGeneric6DofSpringConstraint physicsObject.body, transform, true
    
    @constraint.setLinearLowerLimit Ammo.btVector3.zero()
    @constraint.setLinearUpperLimit Ammo.btVector3.zero()
    
    @constraint.setAngularLowerLimit new Ammo.btVector3 -Math.PI / 2, 0, 0
    @constraint.setAngularUpperLimit new Ammo.btVector3 0, 0, 0
    
    @_dynamicsWorld.addConstraint @constraint
    
  class @Shape extends Pinball.Part.Avatar.ConvexExtrusion
    positionY: -> @properties.axisY
    
    collisionShapeMargin: -> @height / 2
    
    positionSnapping: -> false
    
    rotationStyle: -> @constructor.RotationStyles.Free
  
    meshStyle: -> @constructor.MeshStyles.Extrusion
