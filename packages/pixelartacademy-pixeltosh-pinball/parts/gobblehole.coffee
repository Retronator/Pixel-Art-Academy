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
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/gobblehole.png'
  
  @initialize()
  
  createAvatarProperties: ->
    mass: 0
    height: 0.03
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Wood
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Coarse
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
  
  onBallEnter: (ball) ->
    ball.die()
    
    gameManager = @pinball.gameManager()
    gameManager.addScore @data().score
    gameManager.endBall()
