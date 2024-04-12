AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Pin extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Pin'
  @fullName: -> "pin"
  @description: ->
    "
      The pin in pinball, a small metal pin that changes the ball's trajectory.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/pin.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Cylinder
    Pinball.Part.Avatar.Extrusion
  ]
  
  @initialize()
  
  @radiusRatio = 0.5
  
  constants: ->
    height: 0.03
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Metal
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    radiusRatio: @constructor.radiusRatio
