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

    @capsuleRadius = 0.25
    @capsuleInnerHeight = 1.3
    @capsuleHeight = 2 * @capsuleRadius + @capsuleInnerHeight

    @collisionShape = @createCollisionShape()
    @collisionShape.calculateLocalInertia @mass, @localInertia

    renderObject = @humanAvatar.getRenderObject()
    
    capsuleTransform = new Ammo.btTransform Ammo.btQuaternion.identity(), renderObject.position.toBulletVector3()
    @motionState = new Ammo.btDefaultMotionState capsuleTransform

    @rigidBodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia

    @body = new Ammo.btRigidBody @rigidBodyInfo

    # Do not allow rotation of the physics body to change.
    @setFixedRotation()

    # Disable deactivation so we can manually move the body by direct positioning.
    @body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
    
  createCollisionShape: (options) ->
    occupationMargin = options?.occupationMargin or 0
    capsuleRadius = @capsuleRadius + occupationMargin
    capsuleInnerHeight = @capsuleInnerHeight - 2 * occupationMargin

    capsuleShape = new Ammo.btCapsuleShape capsuleRadius, capsuleInnerHeight
    capsuleTransform = new Ammo.btTransform new Ammo.btQuaternion(0, 0, 0, 1), new Ammo.btVector3(0, @capsuleHeight / 2, 0)

    collisionShape = new Ammo.btCompoundShape
    collisionShape.addChildShape capsuleTransform, capsuleShape

    collisionShape

  createDebugObject: (options) ->
    debugObject = new THREE.Object3D

    occupationMargin = options?.occupationMargin or 0
    capsuleRadius = @capsuleRadius + occupationMargin
    capsuleInnerHeight = @capsuleInnerHeight - 2 * occupationMargin
    renderRadius = capsuleRadius + (options.extrude or 0)

    debugMesh = new THREE.Mesh new THREE.SphereBufferGeometry(renderRadius, 4, 3, 0, Math.PI * 2, 0, Math.PI / 2), options.material
    debugMesh.position.y = capsuleRadius + capsuleInnerHeight
    debugObject.add debugMesh

    debugMesh = new THREE.Mesh new THREE.CylinderBufferGeometry(renderRadius, renderRadius, capsuleInnerHeight, 4, 2, true), options.material
    debugMesh.position.y = @capsuleHeight / 2
    debugObject.add debugMesh

    debugMesh = new THREE.Mesh new THREE.SphereBufferGeometry(renderRadius, 4, 3, 0, Math.PI * 2, Math.PI / 2, Math.PI), options.material
    debugMesh.position.y = capsuleRadius
    debugObject.add debugMesh

    debugObject
