AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar.PhysicsObject extends AR.PhysicsObject
  constructor: (@entity, @properties, @shape, @existingResources) ->
    super arguments...

    transform = new Ammo.btTransform Ammo.btQuaternion.identity(), Ammo.btVector3.zero()
    @motionState = new Ammo.btDefaultMotionState transform

    @mass = @properties.mass ? 0
    @localInertia = Ammo.btVector3.zero()
    
    if @existingResources?.collisionShape
      @collisionShape = @existingResources.collisionShape
      
    else
      @collisionShape = @shape.createCollisionShape()
      margin = @shape.collisionShapeMargin()
      @collisionShape.setMargin margin if margin?
    
    @collisionShape.calculateLocalInertia @mass, @localInertia
    bodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
    @body = new Ammo.btRigidBody bodyInfo
    @body.physicsObject = @
    
    if @properties.continuousCollisionDetection and @shape.continuousCollisionDetectionRadius
      @body.setCcdSweptSphereRadius @shape.continuousCollisionDetectionRadius
      @body.setCcdMotionThreshold Pinball.PhysicsManager.continuousCollisionDetectionThreshold

    # Default body will be elastic and frictionless.
    @body.setRestitution @properties.restitution ? 1
    @body.setFriction @properties.friction ? 0
    @body.setRollingFriction @properties.rollingFriction ? 0
    
  reset: ->
    @setPosition
      x: @properties.position.x
      y: @shape.yPosition()
      z: @properties.position.y
    
    @setRotation @properties.rotationQuaternion or new THREE.Quaternion
    
    @setLinearVelocity new THREE.Vector3
    @setAngularVelocity new THREE.Quaternion
