LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Parts.Walls extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Walls'
  @fullName: -> "walls"
  @description: ->
    "
      The edges of the playfield.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/ballguides.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Extrusion
  ]
  
  @selectable: -> false
  
  @initialize()
  
  constants: ->
    height: 0.02
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Wood
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Coarse
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
