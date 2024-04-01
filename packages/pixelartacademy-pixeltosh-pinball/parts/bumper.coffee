AE = Artificial.Everywhere
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

_displacedRingPosition = new THREE.Vector3

class Pinball.Parts.Bumper extends Pinball.Part
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Parts.Bumper'
  @fullName: -> "bumper"
  @description: ->
    "
      A mushroom-shaped target. An active bumper kicks the ball away when hit.
    "
    
  @imageUrl: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/bumper.png'
  
  @avatarShapes: -> [
    Pinball.Part.Avatar.Extrusion
  ]
  
  @initialize()
  
  @physicsDebugMaterial = new THREE.MeshStandardMaterial color: 0xaaaaaa
  
  constructor: ->
    super arguments...
    
    @trigger = new AR.Trigger
      onEnter: (rigidBody) =>
        return unless rigidBody.physicsObject?.entity instanceof Pinball.Ball
        
        @onBallEnter()
        
    @triggerShape = new AE.LiveComputedField =>
      return unless shape = @avatar.shape()
      properties = @extraShapeProperties()
      
      Pinball.Part.Avatar.Silhouette.detectShape shape.pixelArtEvaluation,
        yOffset: -properties.positionY + 0.001
    
    @triggerCollider = new AE.LiveComputedField =>
      return unless triggerShape = @triggerShape()
      
      triggerCollider = new Ammo.btGhostObject
      triggerCollider.setCollisionShape triggerShape.createCollisionShape()
      triggerCollider
      
    @ringShape = new AE.LiveComputedField =>
      return unless shape = @avatar.shape()
      properties = @extraShapeProperties()
      ballPositionY = @pinball.sceneManager().ballPositionY()
      
      Pinball.Part.Avatar.TaperedExtrusion.detectShape shape.pixelArtEvaluation,
        height: ballPositionY
        taperDistance: ballPositionY
        flipped: properties.flipped
        positionY: ballPositionY * 3
    
    # Add active bumper ring.
    @triggerPhysicsDebugMesh = new AE.LiveComputedField (computation) =>
      return unless triggerShape = @triggerShape()
      return unless renderObject = @getRenderObject()
      
      @_triggerPhysicsDebugGeometry?.dispose()
      @_triggerPhysicsDebugMesh?.removeFromParent()

      return unless @data().active
      
      @_triggerPhysicsDebugGeometry = triggerShape.createPhysicsDebugGeometry()
      
      @_triggerPhysicsDebugMesh = new THREE.Mesh @_triggerPhysicsDebugGeometry, @constructor.physicsDebugMaterial
      @_triggerPhysicsDebugMesh.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
      @_triggerPhysicsDebugMesh.receiveShadow = true
      @_triggerPhysicsDebugMesh.castShadow = true
      
      renderObject.perpendicularRotationOrigin.add @_triggerPhysicsDebugMesh
      
      @_triggerPhysicsDebugMesh
    
    @ringPhysicsDebugMesh = new AE.LiveComputedField (computation) =>
      return unless ringShape = @ringShape()
      return unless renderObject = @getRenderObject()
      
      @_ringPhysicsDebugGeometry?.dispose()
      @_ringPhysicsDebugMesh?.removeFromParent()
      
      return unless @data().active
      
      @_ringPhysicsDebugGeometry = ringShape.createPhysicsDebugGeometry()
      
      @_ringPhysicsDebugMesh = new THREE.Mesh @_ringPhysicsDebugGeometry, @constructor.physicsDebugMaterial
      @_ringPhysicsDebugMesh.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
      @_ringPhysicsDebugMesh.receiveShadow = true
      @_ringPhysicsDebugMesh.castShadow = true
      
      renderObject.perpendicularRotationOrigin.add @_ringPhysicsDebugMesh
      
      @_ringPhysicsDebugMesh
      
    @ringPhysicsObject = new AE.LiveComputedField (computation) =>
      @_ringPhysicsObject?.destroy()

      return unless ringShape = @ringShape()
      
      constants =
        restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
        friction: Pinball.PhysicsManager.FrictionConstants.Metal
        rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
        collisionGroup: Pinball.PhysicsManager.CollisionGroups.Actuators
        collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
      
      @_ringPhysicsObject = new Pinball.Part.Avatar.PhysicsObject
        shape: => ringShape
        constants: => constants
        physicsProperties: => constants
        position: => @position()
        rotationQuaternion: => @rotationQuaternion()
      
      @_ringPhysicsObject
  
  destroy: ->
    super arguments...
    
    @triggerShape.stop()
    @triggerCollider.stop()
    @triggerPhysicsDebugMesh.stop()
    
    @ringShape.stop()
    @ringPhysicsDebugMesh.stop()
    @ringPhysicsObject.stop()
    
    @_triggerPhysicsDebugGeometry?.dispose()
    @_ringPhysicsDebugGeometry?.dispose()
    @_ringPhysicsObject?.destroy()
  
  settings: ->
    active:
      name: 'Active'
      type: Pinball.Interface.Settings.Boolean.id()
      default: true
    kickSpeed:
      name: 'Kick speed'
      unit: "m/s"
      type: Pinball.Interface.Settings.Number.id()
      min: 0.01
      max: 0.5
      step: 0.01
      default: 0.1
    points:
      name: 'Points'
      type: Pinball.Interface.Settings.Number.id()
      default: 0
      
  constants: ->
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Plastic
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
  
  extraShapeProperties: ->
    ballPositionY = @pinball.sceneManager().ballPositionY()
    
    positionY: ballPositionY * 4
    height: ballPositionY
    
  getPhysicsObject: ->
    # To ensure the ring physics object is ready when the main
    # one is inserted to the dynamics world, we depend on it here.
    return unless @ringPhysicsObject()
    
    super arguments...
    
  onAddedToDynamicsWorld: (dynamicsWorld) ->
    ringPhysicsObject = @ringPhysicsObject()
    constants = ringPhysicsObject.entity.constants()
    dynamicsWorld.addRigidBody ringPhysicsObject.body, constants.collisionGroup, constants.collisionMask

    ringPhysicsObject.body.setCollisionFlags ringPhysicsObject.body.getCollisionFlags() | Ammo.btCollisionObject.CollisionFlags.KinematicObject
    ringPhysicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
    
  onRemovedFromDynamicsWorld: (dynamicsWorld) ->
    ringPhysicsObject = @ringPhysicsObject()
    dynamicsWorld.removeRigidBody ringPhysicsObject.body
  
  reset: ->
    super arguments...
    
    if ringPhysicsObject = @ringPhysicsObject?()
      ringPhysicsObject.reset()
      @ringOrigin = ringPhysicsObject.getPosition()
      
    @moving = 0
    @displacement = 0
  
  onBallEnter: ->
    data = @data()
    @moving = 1 if data.active
    
    @pinball.gameManager().addPoints data.points if data.points
  
  update: ->
    return unless physicsObject = @getPhysicsObject()
    return unless triggerCollider = @triggerCollider()
    return unless ringPhysicsObject = @ringPhysicsObject()
    return unless ringPhysicsDebugMesh = @ringPhysicsDebugMesh()
    
    # Query the trigger.
    triggerCollider.setWorldTransform physicsObject.body.getWorldTransform()
    
    @trigger.test triggerCollider, @pinball.physicsManager().dynamicsWorld
    
    # Align the ring's debug mesh to its physics object.
    renderObject = @getRenderObject()
    
    ringPhysicsObject.getPosition _displacedRingPosition
    _displacedRingPosition.sub renderObject.position
    
    ringPhysicsDebugMesh.position.copy _displacedRingPosition
    
  fixedUpdate: (elapsed) ->
    return unless @moving
    return unless ringPhysicsObject = @ringPhysicsObject()
    
    maxDisplacement = @ringOrigin.y / 3
    
    if @moving > 0
      if @displacement >= maxDisplacement
        # We reached maximum displacement, reverse direction.
        @displacement = maxDisplacement
        speed = 0
        @moving = -1
        
      else
        # Keep lowering the ring.
        speed = @data().kickSpeed
    
    else
      if @displacement < 0
        # We reached the origin.
        @moving = 0
        @displacement = 0
        speed = 0
        
      else
        # Keep rising the ring.
        speed = -@data().kickSpeed
    
    distance = speed * elapsed
    @displacement += distance
    
    _displacedRingPosition.copy @ringOrigin
    _displacedRingPosition.y -= @displacement
    ringPhysicsObject.setPosition _displacedRingPosition
