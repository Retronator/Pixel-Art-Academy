AR = Artificial.Reality

class AR.PhysicsObject
  constructor: ->
    # Provides support for autorun calls that stop when physics object is destroyed.
    @_autorunHandles = []

    @_transform = new Ammo.btTransform
    @_vector3 = new Ammo.btVector3
    @_quaternion = new Ammo.btQuaternion

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

  getPosition: ->
    @motionState.getWorldTransform @_transform
    @_transform.getOrigin().toObject()

  getPositionTo: (target) ->
    @motionState.getWorldTransform @_transform
    origin = @_transform.getOrigin()
    target.x = origin.x()
    target.y = origin.y()
    target.z = origin.z()

  setPosition: (position) ->
    @motionState.getWorldTransform @_transform

    @_vector3.copy position
    @_transform.setOrigin @_vector3
    @motionState.setWorldTransform @_transform

    # Also set it directly on body if it's not a kinematic object.
    @body.setWorldTransform @_transform unless @body.isKinematicObject()

  getRotation: ->
    @motionState.getWorldTransform @_transform
    @_transform.getRotation().toObject()

  setRotation: (rotation) ->
    @motionState.getWorldTransform @_transform

    @_quaternion.copy rotation
    @_transform.setRotation @_quaternion
    @motionState.setWorldTransform @_transform

    # Also set it directly on body if it's not a kinematic object.
    @body.setWorldTransform @_transform unless @body.isKinematicObject()
    
  setFixedRotation: (value = true) ->
    @hasFixedRotation = value
    @body.setAngularFactor if value then 0 else 1
