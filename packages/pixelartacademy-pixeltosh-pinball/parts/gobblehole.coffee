AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.GobbleHole extends Pinball.Parts.Hole
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.GobbleHole'
  @fullName: -> "gobble hole"
  @description: ->
    "
      A hole in the playfield that ends the current ball.
    "
    
  @assetId: -> Pinball.Assets.GobbleHole.id()
  
  @initialize()
  
  @placeableRequiredTask: -> LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.DrawGobbleHole
  
  settings: ->
    points:
      name: 'Points'
      type: Pinball.Interface.Settings.Number.id()
      default: 1000
      
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
    
    @pinball.audioManager().gobbleHole()
    
    return unless points = @data().points
    @pinball.gameManager().addPoints points
