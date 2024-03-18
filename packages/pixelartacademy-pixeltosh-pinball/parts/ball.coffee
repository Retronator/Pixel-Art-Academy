LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball
CollisionGroups = Pinball.PhysicsManager.CollisionGroups

class Pinball.Parts.Ball extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Ball'
  @fullName: -> "ball"
  @description: ->
    "
      Marks the place where the ball will spawn.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/ball.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Sphere
    Pinball.Part.Avatar.ConvexExtrusion
  ]
  
  @initialize()
  
  createAvatarProperties: ->
    mass: 0.086 # kg
    restitution: Pinball.PhysicsManager.BallConstants.Restitution
    friction: Pinball.PhysicsManager.BallConstants.Friction
    rollingFriction: Pinball.PhysicsManager.BallConstants.RollingFriction
    collisionGroup: CollisionGroups.Balls
    collisionMask: CollisionGroups.Balls | CollisionGroups.BallGuides | CollisionGroups.Actuators
    continuousCollisionDetection: true
