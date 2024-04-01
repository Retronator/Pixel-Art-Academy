AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Trough extends Pinball.Parts.Hole
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Trough'
  @fullName: -> "ball trough"
  @description: ->
    "
      A hole in the playfield that collects and ends the current ball.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/trough.png'
  
  @triggerPositionYRatio: -> 1
  
  @initialize()
  
  constants: ->
    height: 0.01
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Wood
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Coarse
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    physicsDebugMaterial: Pinball.Parts.Playfield.physicsDebugMaterial

  onBallEnter: (ball) ->
    ball.die()
    @pinball.gameManager().removeBall ball
