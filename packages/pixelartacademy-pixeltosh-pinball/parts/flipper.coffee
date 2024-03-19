AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Flipper extends Pinball.Part
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
  
  @angularSpeed = 30 # rad / s
  
  @rotationAxis = new THREE.Vector3 0, -1, 0
  
  constructor: (@pinball, @properties) ->
    super arguments...
    
    @active = false
    @moving = false
    @displacementAngle = 0
  
  createAvatarProperties: ->
    mass: 0
    height: 0.03
    bitmapOrigin:
      x: 3.5
      y: 3.5
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Plastic
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.Actuators
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls

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
    
    maxDisplacement = AR.Conversions.degreesToRadians @data().maxAngleDegrees
    displacementSign = Math.sign maxDisplacement
    positiveMaxDisplacement = maxDisplacement * displacementSign
    positiveDisplacement = @displacementAngle * displacementSign
    
    if @active
      if positiveDisplacement >= positiveMaxDisplacement
        # We reached maximum displacement, stop.
        @displacementAngle = maxDisplacement
        angularSpeed = 0
        
      else
        # Keep activating the flipper.
        angularSpeed = @constructor.angularSpeed * displacementSign
    
    else
      if positiveDisplacement < 0
        # We reached the origin.
        @moving = false
        @displacementAngle = 0
        angularSpeed = 0
        
      else
        # Keep deactivating the flipper.
        angularSpeed = -@constructor.angularSpeed * displacementSign
    
    angleChange = angularSpeed * elapsed
    @displacementAngle += angleChange
    
    rotation = new THREE.Quaternion().setFromAxisAngle @constructor.rotationAxis, @displacementAngle
    
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.setRotation rotation
