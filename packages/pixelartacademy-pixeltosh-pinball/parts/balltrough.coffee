AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.BallTrough extends Pinball.Parts.Hole
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.BallTrough'
  @fullName: -> "ball trough"
  @description: ->
    "
      A hole in the playfield that collects and ends the current ball.
    "
    
  @assetId: -> Pinball.Assets.BallTrough.id()
  
  @triggerPositionYRatio: -> 1
  
  @initialize()
  
  @placeableRequiredTask: -> LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.DrawBallTrough
  
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
