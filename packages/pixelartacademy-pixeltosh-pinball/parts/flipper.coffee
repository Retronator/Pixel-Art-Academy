AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Flipper extends Pinball.Part
  # maxAngleDegrees: the amount the flipper displaces when engaged
  # angularSpeedDegrees: the amount of degrees per second the flipper rotates at
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Flipper'
  @fullName: -> "flipper"
  @description: ->
    "
      A tapered bat that lets the player control the ball.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/flipper.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Extrusion
  ]
  
  @initialize()
  
  @rotationAxis = new THREE.Vector3 0, 1, 0
  
  constructor: ->
    super arguments...
    
    @active = false
    @moving = false
    @displacementAngle = 0
  
  defaultData: ->
    maxAngleDegrees: 39.5
    
  settings: ->
    maxAngleDegrees:
      name: 'Angle range'
      unit: "°"
      type: Pinball.Interface.Settings.Number.id()
      min: 1
      max: 180
      step: 1
      default: 45
    angularSpeedDegrees:
      name: 'Speed'
      unit: "°/s"
      type: Pinball.Interface.Settings.Number.id()
      min: 100
      max: 4000
      step: 100
      default: 2000
  
  constants: ->
    bitmapOrigin:
      x: 3.5
      y: 3.5
    restitution: Pinball.PhysicsManager.RestitutionConstants.Rubber
    friction: Pinball.PhysicsManager.FrictionConstants.Rubber
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Rubber
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.Actuators
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    
  extraShapeProperties: ->
    height: @pinball.sceneManager().ballYPosition() * 2

  onAddedToDynamicsWorld: (@dynamicsWorld) ->
    # Flipper is a player-controlled kinematic object.
    physicsObject = @avatar.getPhysicsObject()
    @origin = physicsObject.getPosition()
    
    physicsObject.body.setCollisionFlags physicsObject.body.getCollisionFlags() | Ammo.btCollisionObject.CollisionFlags.KinematicObject
    physicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
    
  reset: ->
    super arguments...
    
    @active = false
    @moving = false
    @displacementAngle = 0
    
  activate: ->
    @active = true
    @moving = true
    
    physicsObject = @avatar.getPhysicsObject()
    
    rotation = THREE.Quaternion.fromObject physicsObject.getRotation()
    rotationAngles = new THREE.Euler().setFromQuaternion rotation
    @displacementAngle = rotationAngles.y
  
  deactivate: ->
    @active = false
    
  fixedUpdate: (elapsed) ->
    return unless @moving
    
    data = @data()
    
    maxDisplacement = AR.Conversions.degreesToRadians data.maxAngleDegrees
    displacementSign = if @data().flipped then -1 else 1
    positiveDisplacement = @displacementAngle * displacementSign
    
    angularSpeed = AR.Conversions.degreesToRadians data.angularSpeedDegrees
    
    if @active
      if positiveDisplacement >= maxDisplacement
        # We reached maximum displacement, stop.
        @displacementAngle = maxDisplacement * displacementSign
        angularSpeed = 0
        
      else
        # Keep activating the flipper.
        angularSpeed = angularSpeed * displacementSign
    
    else
      if positiveDisplacement < 0
        # We reached the origin.
        @moving = false
        @displacementAngle = 0
        angularSpeed = 0
        
      else
        # Keep deactivating the flipper.
        angularSpeed = -angularSpeed * displacementSign
    
    angleChange = angularSpeed * elapsed
    @displacementAngle += angleChange
    
    rotation = new THREE.Quaternion().setFromAxisAngle @constructor.rotationAxis, @rotationAngle() + @displacementAngle
    
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.setRotation rotation
