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
  @description: -> "A target that scores points when hit."
  
  @translations: ->
    passiveActive: "A passive bumper just bounces away the ball, while an active one kicks it away with force."
  
  description: ->
    description = super arguments...
    activeEnabled = @settings().active.enabledCondition @data()
    return description unless activeEnabled
    return description unless translations = @translations()
    
    "#{description} #{translations.passiveActive}"
    
  @assetId: -> Pinball.Assets.Bumper.id()
  
  @avatarShapes: -> [
    @Shape
  ]
  
  @initialize()
  
  @placeableRequiredTask: -> LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.DrawBumper
  
  @ringTriggerDebugMaterial = new THREE.MeshStandardMaterial color: 0xaa6666
  @ringDebugMaterial = new THREE.MeshStandardMaterial color: 0x66aaaa
  
  constructor: ->
    super arguments...
    
    @trigger = new AR.Trigger
      onEnter: (rigidBody) =>
        return unless rigidBody.physicsObject?.entity instanceof Pinball.Ball
        
        @onBallEnter()
        
    # Add passive bumper trigger for gaining points.
    @towerTriggerShape = new AE.LiveComputedField =>
      return if @data().active
      return unless shape = @avatar.shape()
      
      properties = @extraShapeProperties()
      ballPositionY = @pinball.sceneManager().ballPositionY()
      
      Pinball.Part.Avatar.Extrusion.detectShape shape.pixelArtEvaluation,
        height: ballPositionY * 3
        flipped: properties.flipped
        positionY: ballPositionY * 3
        
    @towerTriggerCollider = new AE.LiveComputedField =>
      return if @data().active
      return unless triggerShape = @towerTriggerShape()
      
      triggerCollider = new Ammo.btGhostObject
      triggerCollider.setCollisionShape triggerShape.createCollisionShape()
      triggerCollider
      
    # Add active bumper trigger for lowering the ring.
    @ringTriggerShape = new AE.LiveComputedField =>
      return unless @data().active
      return unless shape = @avatar.shape()
      properties = @extraShapeProperties()
      
      Pinball.Part.Avatar.Silhouette.detectShape shape.pixelArtEvaluation,
        yOffset: -properties.positionY + 0.001
    
    @ringTriggerCollider = new AE.LiveComputedField =>
      return unless @data().active
      return unless triggerShape = @ringTriggerShape()
      
      triggerCollider = new Ammo.btGhostObject
      triggerCollider.setCollisionShape triggerShape.createCollisionShape()
      triggerCollider
      
    @ringTriggerPhysicsDebugMesh = new AE.LiveComputedField (computation) =>
      @_triggerPhysicsDebugGeometry?.dispose()
      @_triggerPhysicsDebugMesh?.removeFromParent()
      
      return unless @data().active
      return unless triggerShape = @ringTriggerShape()
      return unless renderObject = @getRenderObject()
      
      @_triggerPhysicsDebugGeometry = triggerShape.createPhysicsDebugGeometry()
      
      @_triggerPhysicsDebugMesh = new THREE.Mesh @_triggerPhysicsDebugGeometry, @constructor.ringTriggerDebugMaterial
      @_triggerPhysicsDebugMesh.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
      @_triggerPhysicsDebugMesh.receiveShadow = true
      @_triggerPhysicsDebugMesh.castShadow = true
      
      renderObject.perpendicularRotationOrigin.add @_triggerPhysicsDebugMesh
      
      @_triggerPhysicsDebugMesh

    # Add active bumper ring.
    @ringShape = new AE.LiveComputedField =>
      return unless @data().active
      return unless shape = @avatar.shape()

      properties = @extraShapeProperties()
      ballPositionY = @pinball.sceneManager().ballPositionY()
      
      Pinball.Part.Avatar.TaperedExtrusion.detectShape shape.pixelArtEvaluation,
        height: ballPositionY
        taperDistanceTop: 0
        taperDistanceBottom: ballPositionY
        flipped: properties.flipped
        positionY: ballPositionY * 3
    
    @ringPhysicsDebugMesh = new AE.LiveComputedField (computation) =>
      @_ringPhysicsDebugGeometry?.dispose()
      @_ringPhysicsDebugMesh?.removeFromParent()
      
      return unless @data().active
      return unless ringShape = @ringShape()
      return unless renderObject = @getRenderObject()
      
      @_ringPhysicsDebugGeometry = ringShape.createPhysicsDebugGeometry()
      
      @_ringPhysicsDebugMesh = new THREE.Mesh @_ringPhysicsDebugGeometry, @constructor.ringDebugMaterial
      @_ringPhysicsDebugMesh.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
      @_ringPhysicsDebugMesh.receiveShadow = true
      @_ringPhysicsDebugMesh.castShadow = true
      
      renderObject.perpendicularRotationOrigin.add @_ringPhysicsDebugMesh
      
      @_ringPhysicsDebugMesh
      
    @ringPhysicsObject = new AE.LiveComputedField (computation) =>
      if @_ringPhysicsObject
        @_removeRingRigidBody()
        @_ringPhysicsObject?.destroy()
        @_ringPhysicsObject = null
      
      return unless @data().active
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
      
      @_ringPhysicsObject.body.setCollisionFlags @_ringPhysicsObject.body.getCollisionFlags() | Ammo.btCollisionObject.CollisionFlags.KinematicObject
      @_ringPhysicsObject.body.setActivationState Ammo.btCollisionObject.ActivationStates.DisableDeactivation
      
      @_ringPhysicsObject
  
  destroy: ->
    super arguments...
    
    @towerTriggerShape.stop()
    @towerTriggerCollider.stop()
  
    @ringTriggerShape.stop()
    @ringTriggerCollider.stop()
    @ringTriggerPhysicsDebugMesh.stop()
    
    @ringShape.stop()
    @ringPhysicsDebugMesh.stop()
    @ringPhysicsObject.stop()
    
    @_triggerPhysicsDebugGeometry?.dispose()
    @_ringPhysicsDebugGeometry?.dispose()
    @_ringPhysicsObject?.destroy()
    
    @_activeBumperPartsAutorun?.stop()
    @_removeRingRigidBody()
  
  settings: ->
    active:
      name: 'Active'
      type: Pinball.Interface.Settings.Boolean.id()
      default: false
      enabledCondition: (data) => LM.PixelArtFundamentals.Fundamentals.Goals.Pinball.DrawLowerThird.getAdventureInstance()?.completed()
    passiveRestitution:
      name: 'Bounciness'
      type: Pinball.Interface.Settings.Number.id()
      min: 0
      max: 1
      step: 0.1
      default: 1
      enabledCondition: (data) => not data.active
    kickSpeed:
      name: 'Kick speed'
      unit: "m/s"
      type: Pinball.Interface.Settings.Number.id()
      min: 0.1
      max: 0.5
      step: 0.01
      default: 0.3
      enabledCondition: (data) => data.active
    points:
      name: 'Points'
      type: Pinball.Interface.Settings.Number.id()
      default: 10
      
  constants: ->
    restitution: Pinball.PhysicsManager.RestitutionConstants.HardSurface
    friction: Pinball.PhysicsManager.FrictionConstants.Plastic
    rollingFriction: Pinball.PhysicsManager.RollingFrictionConstants.Smooth
    collisionGroup: Pinball.PhysicsManager.CollisionGroups.BallGuides
    collisionMask: Pinball.PhysicsManager.CollisionGroups.Balls
    
  shapeDataPropertyNames: ->
    super(arguments...).concat ['active']
  
  extraShapeProperties: ->
    return unless sceneManager = @pinball.sceneManager()
    ballPositionY = sceneManager.ballPositionY()
    
    positionY: ballPositionY * 4
    ballPositionY: ballPositionY
    
  extraPhysicsProperties: ->
    data = @data()
    constants = @constants()
    
    restitution: if data.active then constants.restitution else data.passiveRestitution / Pinball.PhysicsManager.BallConstants.Restitution
    
  getPhysicsObject: ->
    if @data().active
      # To ensure the ring physics object is ready when the main
      # one is inserted to the dynamics world, we depend on it here.
      return unless @ringPhysicsObject()
    
    super arguments...
    
  onAddedToDynamicsWorld: (@_dynamicsWorld) ->
    # Reactively add active bumper parts.
    Tracker.nonreactive =>
      @_activeBumperPartsAutorun = Tracker.autorun =>
        @_removeRingRigidBody()
        
        return unless ringPhysicsObject = @ringPhysicsObject()
        
        @_ringRigidBody = ringPhysicsObject.body
        
        constants = @constants()
        @_dynamicsWorld.addRigidBody @_ringRigidBody, constants.collisionGroup, constants.collisionMask
    
  onRemovedFromDynamicsWorld: (dynamicsWorld) ->
    @_activeBumperPartsAutorun?.stop()
    @_activeBumperPartsAutorun = null
    @_removeRingRigidBody()
    @_dynamicsWorld = null
  
  _removeRingRigidBody: ->
    return unless @_ringRigidBody and @_dynamicsWorld
    
    @_dynamicsWorld.removeRigidBody @_ringRigidBody
    @_ringRigidBody = null
  
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
    
    if @data().active
      return unless triggerCollider = @ringTriggerCollider()
      
      # Align the ring's debug mesh to its physics object.
      return unless ringPhysicsObject = @ringPhysicsObject()
      return unless ringPhysicsDebugMesh = @ringPhysicsDebugMesh()
      
      renderObject = @getRenderObject()
      
      ringPhysicsObject.getPosition _displacedRingPosition
      _displacedRingPosition.sub renderObject.position
      
      ringPhysicsDebugMesh.position.copy _displacedRingPosition
      
    else
      return unless triggerCollider = @towerTriggerCollider()
      
    # Query the trigger.
    triggerCollider.setWorldTransform physicsObject.body.getWorldTransform()
    @trigger.test triggerCollider, @pinball.physicsManager().dynamicsWorld
  
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

  class @Shape extends Pinball.Part.Avatar.TriangleMesh
    @detectShape: (pixelArtEvaluation, properties) ->
      return unless pixelArtEvaluation.layers[0].cores.length
      
      new @ pixelArtEvaluation, properties
      
    constructor: (@pixelArtEvaluation, @properties) ->
      super arguments...
      
      individualGeometryData = []
      ballPositionY = @properties.ballPositionY
      
      ballRadiusBitmap = ballPositionY / Pinball.CameraManager.orthographicPixelSize
      
      if @properties.active
        towerTaperDistance = 1.5 * ballRadiusBitmap
        
      else
        towerTaperDistance = 0.5 * ballRadiusBitmap
      
      for core in @pixelArtEvaluation.layers[0].cores
        topBoundaries = []
        
        for line in core.outlines
          points = @_getLinePoints line
          topBoundary = new AP.PolygonBoundary points
          topBoundaries.push topBoundary
          
        topPolygon = new AP.PolygonWithHoles topBoundaries
        topPolygonWithoutHoles = topPolygon.getPolygonWithoutHoles()
        individualGeometryData.push @constructor._createExtrudedVerticesAndIndices topPolygon.boundaries,  -ballPositionY, 0, @properties.flipped
        individualGeometryData.push @constructor._createPolygonVerticesAndIndices topPolygonWithoutHoles, 0, 1
        individualGeometryData.push @constructor._createPolygonVerticesAndIndices topPolygonWithoutHoles, -ballPositionY, -1
        
        towerPolygon = topPolygon.getInsetPolygon towerTaperDistance
        
        for boundary, boundaryIndex in topPolygon.boundaries
          for vertex, vertexIndex in boundary.vertices
            towerPolygon.boundaries[boundaryIndex].vertices[vertexIndex].tangent = vertex.tangent
        
        individualGeometryData.push @constructor._createExtrudedVerticesAndIndices towerPolygon.boundaries,  -ballPositionY * 4, -ballPositionY, @properties.flipped
        
      @geometryData = @constructor._mergeGeometryData individualGeometryData
    
    positionY: -> @properties.positionY
