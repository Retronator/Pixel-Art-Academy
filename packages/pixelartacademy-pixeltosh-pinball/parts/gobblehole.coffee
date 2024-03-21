AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.GobbleHole extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.GobbleHole'
  @fullName: -> "gobble hole"
  @description: ->
    "
      A hole in the playfield that ends the current ball.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/gobblehole.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Depression
  ]
  
  @initialize()
  
  constructor: ->
    super arguments...
    
    @trigger = new AR.Trigger
      onEnter: (rigidBody) =>
        return unless rigidBody.physicsObject.entity instanceof Pinball.Ball

        ball = rigidBody.physicsObject.entity
        return if ball.state() is Pinball.Ball.States.Dead
        
        ball.die()
        @pinball.gameManager().endBall()
        
  createAvatarProperties: ->
    mass: 0
    height: 0.03
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Wood
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Coarse
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
  
  playfieldHoleBoundaries: -> @avatar.getHoleBoundaries()

  update: ->
    return unless physicsObject = @avatar.getPhysicsObject()
    @trigger.test physicsObject.body, @pinball.physicsManager().dynamicsWorld
