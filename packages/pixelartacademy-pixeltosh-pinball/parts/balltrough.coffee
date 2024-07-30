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
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Wood
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Coarse
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    physicsDebugMaterial: Pinball.Parts.Playfield.physicsDebugMaterial

  extraShapeProperties: ->
    return unless sceneManager = @pinball.sceneManager()
    
    height: sceneManager.ballPositionY() * 4
    
  onBallEnter: (ball) ->
    ball.die()
    
    Meteor.setTimeout =>
      @pinball.gameManager().removeBall ball
    ,
      1000
