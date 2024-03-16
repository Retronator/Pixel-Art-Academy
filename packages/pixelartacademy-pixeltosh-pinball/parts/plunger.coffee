LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Plunger extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Plunger'
  @fullName: -> "plunger"
  @description: ->
    "
      A player-controlled, spring-loaded rod that allows the player to send the ball into the game.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/plunger.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Box
  ]
  
  @initialize()
  
  @pullingSpeed = 0.05 # m / s
  @releaseSpeed = 0.75 # m / s
  
  constructor: ->
    super arguments...
    
    @active = false
    @moving = false
    @displacement = 0

  createAvatar: ->
    new Pinball.Part.Avatar @,
      mass: 0
      height: 0.05
      restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
      friction: Pinball.PhysicsManager.FrictionConstants.Plastic
      rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
      collisionGroup: Pinball.PhysicsManager.CollisionGroups.Actuators
      collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
  
  onAddedToDynamicsWorld: (@dynamicsWorld) ->
    # Create a constraint at the plunger origin.
    physicsObject = @avatar.getPhysicsObject()
    @origin = physicsObject.getPosition()
    
    physicsObject.body.setCollisionFlags physicsObject.body.getCollisionFlags() | Ammo.btCollisionObject.CollisionFlags.KinematicObject
  
  onRemovedFromDynamicsWorld: (dynamicsWorld) ->
    @dynamicsWorld.removeConstraint @constraint
    
  activate: ->
    @active = true
    @moving = true
    
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
    
    @handConstraint = new Ammo.btPoint2PointConstraint physicsObject.body, Ammo.btVector3.zero()
    @dynamicsWorld.addConstraint @handConstraint
    
    @displacement = physicsObject.getPosition().z - @origin.z
  
  deactivate: ->
    @active = false
    
  update: (appTime) ->
    return unless @moving
    
    physicsObject = @avatar.getPhysicsObject()

    if @active
      distance = @constructor.pullingSpeed * appTime.elapsedAppTime
      @displacement = Math.min @displacement + distance, physicsObject.shape.depth
      
    else
      distance = @constructor.releaseSpeed * appTime.elapsedAppTime * @displacement / physicsObject.shape.depth
      @displacement = Math.max @displacement - distance, 0
      
      if @displacement < Pinball.CameraManager.orthographicPixelSize
        @moving = false
        @displacement = 0
        physicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.WantsDeactivation
    
    physicsObject.setPosition x: @origin.x, y: @origin.y, z: @origin.z + @displacement
