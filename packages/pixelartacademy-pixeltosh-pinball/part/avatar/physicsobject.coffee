AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.PhysicsObject extends AR.PhysicsObject
  constructor: (@entity, @existingResources) ->
    super arguments...
    
    @ready = new ReactiveField false
    
    constants = @entity.constants()
    
    # Create the body when the shape becomes available.
    @autorun (computation) =>
      return unless shape = @entity.shape()
      computation.stop()
      
      @mass = constants.mass ? 0
      @motionState = new Ammo.btDefaultMotionState new Ammo.btTransform Ammo.btQuaternion.identity(), Ammo.btVector3.zero()
      @localInertia = Ammo.btVector3.zero()
      @_createCollisionShape shape
      bodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
      
      @body = new Ammo.btRigidBody bodyInfo
      @body.physicsObject = @
      Ammo.destroy bodyInfo
      
      if constants.continuousCollisionDetection and shape.continuousCollisionDetectionRadius
        @body.setCcdSweptSphereRadius shape.continuousCollisionDetectionRadius
        @body.setCcdMotionThreshold Pinball.PhysicsManager.continuousCollisionDetectionThreshold
      
      Tracker.nonreactive => @reset()
      @ready true
    
    # Update dynamic properties.
    @autorun (computation) =>
      return unless @ready()
      properties = @entity.physicsProperties()

      # Default body will be elastic and frictionless.
      @body.setRestitution properties.restitution  ? 1
      @body.setFriction properties.friction ? 0
      @body.setRollingFriction properties.rollingFriction ? 0
      
    # Update shape.
    @autorun (computation) =>
      return unless shape = @entity.shape()
      @_createCollisionShape shape
      @body.setCollisionShape @collisionShape
      @body.setMassProps @mass, @localInertia
      
      Tracker.nonreactive => @reset()
      
  destroy: ->
    super arguments...
    
    Ammo.destroy @body if @body
    Ammo.destroy @motionState if @motionState
    Ammo.destroy @collisionShape if @collisionShape and not @existingResources?.collisionShape
  
  _createCollisionShape: (shape) ->
    if @existingResources?.collisionShape
      @collisionShape = @existingResources.collisionShape
    
    else
      Ammo.destroy @collisionShape if @collisionShape
      @collisionShape = shape.createCollisionShape()
      margin = shape.collisionShapeMargin()
      @collisionShape.setMargin margin if margin?
    
    @collisionShape.calculateLocalInertia @mass, @localInertia
    
  reset: ->
    return unless shape = @entity.shape()
    return unless position = @entity.position()
    return unless rotation = @entity.rotation()
    
    @setPosition
      x: position.x
      y: shape.yPosition()
      z: position.z
    
    @setRotation rotation
    
    @setLinearVelocity new THREE.Vector3
    @setAngularVelocity new THREE.Quaternion
