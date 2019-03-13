AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.HumanAvatar.PhysicsObject extends AR.PhysicsObject
  constructor: (@humanAvatar) ->
    super arguments...

    @parentItem = @humanAvatar

    @mass = 1
    @localInertia = new Ammo.btVector3 0, 0, 0

    capsuleShape = new Ammo.btCapsuleShape 0.3, 1.2
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

    # Create kinematic body.
    @body.setCollisionFlags @body.getCollisionFlags() | 2

    # Disable deactivation.
    @body.setActivationState 4

    @currentAngle = 0

  update: (appTime) ->
    if @_targetAngle?
      angleDelta = @_angleChangeSpeed * appTime.elapsedAppTime
      @_angleChange += Math.abs angleDelta
      @currentAngle += angleDelta

      if @_angleChange > @_totalAngleChange
        @currentAngle = @_targetAngle
        @_targetAngle = null

  facePosition: (positionOrLandmark) ->
    facingPosition = LOI.adventure.world.getPositionVector positionOrLandmark
    position = THREE.Vector3.fromObject @getPosition()

    @faceDirection new THREE.Vector3().subVectors facingPosition, position

  faceDirection: (direction) ->
    @_targetAngle = LOI.Engine.RenderingSides.getAngleForDirection direction
    @_angleChange = 0
    @_totalAngleChange = _.angleDistance @_targetAngle, @currentAngle
    @_angleChangeSpeed = 4 * Math.sign _.angleDifference @_targetAngle, @currentAngle
