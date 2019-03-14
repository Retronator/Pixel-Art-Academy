AR = Artificial.Reality

class AR.PhysicsObject
  constructor: ->
    # Provides support for autorun calls that stop when physics object is destroyed.
    @_autorunHandles = []

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
    transform = new Ammo.btTransform
    @motionState.getWorldTransform transform
    transform.getOrigin().toObject()

  setPosition: (position) ->
    transform = new Ammo.btTransform
    @motionState.getWorldTransform transform

    transform.setOrigin Ammo.btVector3.fromObject position
    @motionState.setWorldTransform transform

    # Also set it directly on body if it's not a kinematic object.
    @body.setWorldTransform transform unless @body.isKinematicObject()

  getRotation: ->
    transform = new Ammo.btTransform
    @motionState.getWorldTransform transform
    transform.getRotation().toObject()

  setRotation: (rotation) ->
    transform = new Ammo.btTransform
    @motionState.getWorldTransform transform

    transform.setRotation Ammo.btQuaternion.fromObject rotation
    @motionState.setWorldTransform transform

    # Also set it directly on body if it's not a kinematic object.
    @body.setWorldTransform transform unless @body.isKinematicObject()
