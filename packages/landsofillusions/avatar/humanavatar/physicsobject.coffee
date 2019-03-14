AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.HumanAvatar.PhysicsObject extends AR.PhysicsObject
  constructor: (@humanAvatar) ->
    super arguments...

    @parentItem = @humanAvatar

    @walkMass = 75
    @idleMass = 10000
    
    @mass = @idleMass
    @localInertia = new Ammo.btVector3 0, 0, 0

    capsuleShape = new Ammo.btCapsuleShape 0.25, 1.3
    capsuleTransform = new Ammo.btTransform new Ammo.btQuaternion(0, 0, 0, 1), new Ammo.btVector3(0, 0.9, 0)

    @collisionShape = new Ammo.btCompoundShape
    @collisionShape.addChildShape capsuleTransform, capsuleShape
    @collisionShape.calculateLocalInertia @mass, @localInertia

    renderObject = @humanAvatar.getRenderObject()
    
    capsuleTransform = new Ammo.btTransform Ammo.btQuaternion.identity, renderObject.position.toBulletVector3()
    @motionState = new Ammo.btDefaultMotionState capsuleTransform

    @rigidBodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia

    @body = new Ammo.btRigidBody @rigidBodyInfo
    @body.setAngularFactor 0

    # Disable deactivation so we can manually move the body by direct positioning.
    @body.setActivationState 4
