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
  
  @assetId: -> Pinball.Assets.Playfield.id()
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Extrusion
  ]
  
  @initialize()
  
  constants: ->
    height: Pinball.SceneManager.playfieldHeight
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Wood
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Coarse
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
