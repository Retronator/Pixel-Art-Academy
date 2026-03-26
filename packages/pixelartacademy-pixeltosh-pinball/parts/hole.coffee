AE = Artificial.Everywhere
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Hole extends Pinball.Part
  @avatarShapes: -> [
    Pinball.Part.Avatar.Depression
  ]
  
  @triggerPositionYRatio: -> 0.5 # Override to position the trigger elsewhere (1 is top, 0 is bottom).
  
  constructor: ->
    super arguments...
    
    @trigger = new AR.Trigger
      onEnter: (rigidBody) =>
        return unless rigidBody.physicsObject?.entity instanceof Pinball.Ball

        ball = rigidBody.physicsObject.entity
        return if ball.state() is Pinball.Ball.States.Dead
        
        @onBallEnter ball
        
    @triggerCollider = new AE.LiveComputedField =>
      return unless shape = @avatar.shape()
      
      triggerShape = Pinball.Part.Avatar.Silhouette.detectShape shape.pixelArtEvaluation,
        yOffset: shape.height * @constructor.triggerPositionYRatio()
      
      return unless triggerShape
        
      triggerCollider = new Ammo.btGhostObject
      triggerCollider.setCollisionShape triggerShape.createCollisionShape()
      triggerCollider
      
  destroy: ->
    super arguments...
    
    @triggerCollider.stop()
    
  playfieldHoleBoundaries: -> @avatar.getHoleBoundaries()

  update: ->
    return unless physicsObject = @avatar.getPhysicsObject()
    return unless triggerCollider = @triggerCollider()
    
    triggerCollider.setWorldTransform physicsObject.body.getWorldTransform()
    
    @trigger.test triggerCollider, @pinball.physicsManager().dynamicsWorld
    
  onBallEnter: (ball) -> # Override to perform any logic when the ball enters the hole.
