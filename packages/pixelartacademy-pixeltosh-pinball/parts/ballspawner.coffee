LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball
CollisionGroups = Pinball.PhysicsManager.CollisionGroups

class Pinball.Parts.BallSpawner extends Pinball.Part
  # captive: boolean whether the spawned ball is captive
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.BallSpawner'
  @fullName: -> "ball"
  @description: ->
    "
      Marks the place where a ball will spawn.
    "
    
  @assetId: -> Pinball.Assets.Ball.id()
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Sphere
    Pinball.Part.Avatar.ConvexExtrusion
  ]
  
  @initialize()
  
  @placeableRequiredTask: -> LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.DrawBall
  
  settings: ->
    captive:
      name: 'Captive ball'
      type: Pinball.Interface.Settings.Boolean.id()
      
  constants: ->
    restitution: Pinball.PhysicsManager.BallConstants.Restitution
    friction: Pinball.PhysicsManager.BallConstants.Friction
    rollingFriction: Pinball.PhysicsManager.BallConstants.RollingFriction
    collisionGroup: CollisionGroups.Balls
    collisionMask: CollisionGroups.Balls | CollisionGroups.BallGuides | CollisionGroups.Actuators
    continuousCollisionDetection: true

  spawnBall: ->
    ball = new Pinball.Ball @pinball, @
    ball.state Pinball.Ball.States.Captive if @data().captive
    ball