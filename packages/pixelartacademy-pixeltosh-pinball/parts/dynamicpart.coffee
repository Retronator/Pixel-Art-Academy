LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball
CollisionGroups = Pinball.PhysicsManager.CollisionGroups

class Pinball.Parts.DynamicPart extends Pinball.Part
  onAddedToDynamicsWorld: (dynamicsWorld) ->
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
    
    @defaultCollisionFlags = physicsObject.body.getCollisionFlags()
    physicsObject.body.setCollisionFlags @defaultCollisionFlags | Ammo.btCollisionObject.CollisionFlags.KinematicObject
    
  onSimulationStarted: ->
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.body.setCollisionFlags @defaultCollisionFlags
    
  onSimulationEnded: ->
    physicsObject = @avatar.getPhysicsObject()
    physicsObject.body.setCollisionFlags @defaultCollisionFlags | Ammo.btCollisionObject.CollisionFlags.KinematicObject
