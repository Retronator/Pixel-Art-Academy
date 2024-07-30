AR = Artificial.Reality

class AR.PhysicsObject
  constructor: ->
    # Provides support for autorun calls that stop when physics object is destroyed.
    @_autorunHandles = []

    # HACK: It seems we cannot initialize these outside of the class
    # since Ammo doesn't seem to be fully initialized yet in this package.
    @_transform = new Ammo.btTransform
    @_vector3 = new Ammo.btVector3
    @_quaternion = new Ammo.btQuaternion
    @_min = new Ammo.btVector3
    @_max = new Ammo.btVector3

  destroy: ->
    handle.stop() for handle in @_autorunHandles

  autorun: (handler) ->
    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle

  setMass: (mass) ->
    @mass = mass
    @collisionShape?.calculateLocalInertia @mass, @localInertia
    @body?.setMassProps @mass, @localInertia

  getPosition: (result) ->
    result ?= new THREE.Vector3
    @motionState.getWorldTransform @_transform
    result.setFromBulletVector3 @_transform.getOrigin()
    result

  setPosition: (position) ->
    @motionState.getWorldTransform @_transform

    @_vector3.copy position
    @_transform.setOrigin @_vector3
    @motionState.setWorldTransform @_transform

    # Also set it directly on body if it's not a kinematic object.
    @body.setWorldTransform @_transform unless @body.isKinematicObject()

  getRotationQuaternion: (result) ->
    result ?= new THREE.Quaternion
    @motionState.getWorldTransform @_transform
    result.setFromBulletQuaternion @_transform.getRotation()
    result

  setRotationQuaternion: (rotationQuaternion) ->
    @motionState.getWorldTransform @_transform

    @_quaternion.copy rotationQuaternion
    @_transform.setRotation @_quaternion
    @motionState.setWorldTransform @_transform

    # Also set it directly on body if it's not a kinematic object.
    @body.setWorldTransform @_transform unless @body.isKinematicObject()
    
  setFixedRotation: (value = true) ->
    @hasFixedRotation = value
    @body.setAngularFactor if value then 0 else 1

  getLinearVelocity: (result) ->
    result ?= new THREE.Vector3
    result.setFromBulletVector3 @body.getLinearVelocity()
    result
    
  setLinearVelocity: (velocity) ->
    @_vector3.copy velocity
    @body.setLinearVelocity @_vector3
  
  setAngularVelocity: (angularVelocity) ->
    @_quaternion.copy angularVelocity
    @body.setAngularVelocity @_quaternion
    
  getBoundingBox: (result) ->
    result ?= new THREE.Box3
    
    @body.getAabb @_min, @_max
    result.min.setFromBulletVector3 @_min
    result.max.setFromBulletVector3 @_max
    
    result
