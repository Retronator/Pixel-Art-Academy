LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball
CollisionGroups = Pinball.PhysicsManager.CollisionGroups

_rotationQuaternion = new THREE.Quaternion
_rotationAngles = new THREE.Euler

class Pinball.Parts.SpinningTarget extends Pinball.Parts.DynamicPart
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.SpinningTarget'
  @fullName: -> "spinning target"
  @description: ->
    "
      A metal plate that spins when the ball hits its lower half.
    "
    
  @assetId: -> Pinball.Assets.SpinningTarget.id()
  
  @avatarShapes: -> [
    @Shape
  ]
  
  @initialize()
  
  @placeableRequiredTask: -> LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.DrawSpinningTarget
  
  settings: ->
    points:
      name: 'Points'
      type: Pinball.Interface.Settings.Number.id()
      default: 100
      
  constants: ->
    mass: 0.0002
    height: 0.001
    meshHeight: Pinball.CameraManager.orthographicPixelSize
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Metal
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: CollisionGroups.Actuators
    collisionMask: CollisionGroups.Balls

  extraShapeProperties: ->
    return unless sceneManager = @pinball.sceneManager()
    
    axisY: sceneManager.ballPositionY() * 2 + 0.002
    
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
    
    @_toBaseRotationQuaternion = @rotationQuaternion().invert()
    
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
    
  update: (elapsed) ->
    return unless physicsObject = @avatar.getPhysicsObject()

    # Get rotation relative to the base.
    physicsObject.getRotationQuaternion _rotationQuaternion
    _rotationQuaternion.premultiply @_toBaseRotationQuaternion
    _rotationAngles.setFromQuaternion _rotationQuaternion, 'YXZ'
    
    # See if we're in the scoring region (base of the spinner turned to top).
    distanceFromTop = Math.abs _rotationAngles.x + Math.PI / 2
    inScoringRegion = distanceFromTop < 0.5

    # Add points when entering the scoring region.
    if inScoringRegion and not @_wasInScoringRegion
      @pinball.gameManager().addPoints points if points = @data().points
    
    @_wasInScoringRegion = inScoringRegion
    
  class @Shape extends Pinball.Part.Avatar.ConvexExtrusion
    _calculateBitmapOrigin: ->
      # Put all the weight at the bottom of the spinner.
      x: @bitmapRectangle.x() + @bitmapRectangle.width() * 0.5
      y: @bitmapRectangle.bottom() - 0.5
      
    positionY: -> @properties.axisY
    
    collisionShapeMargin: -> @height / 2
    
    positionSnapping: -> false
    
    rotationStyle: -> @constructor.RotationStyles.Free
  
    meshStyle: -> @constructor.MeshStyles.Extrusion
