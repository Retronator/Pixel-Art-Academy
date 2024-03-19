AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

_rotation = new THREE.Quaternion
_rotationAngles = new THREE.Euler

if Meteor.isClient
  _transform = new Ammo.btTransform

class Pinball.Part.Avatar extends LOI.Adventure.Thing.Avatar
  constructor: (part) ->
    super part.constructor

    @part = part
    
    @shape = new ReactiveField null
    
    @_renderObject = new ReactiveField null
    @_physicsObject = new ReactiveField null
    
  destroy: ->
    super arguments...

    @_renderObject()?.destroy()
    @_physicsObject()?.destroy()
  
  # Note: We initialize the avatar separately since the construction happens
  # already in the thing's constructor and we don't have any extra fields available.
  initialize: ->
    @part.autorun =>
      return unless properties = @part.avatarProperties()
      
      # Analyze the bitmap to determine the shape of the part.
      return unless bitmap = @part.bitmap()
      pixelArtEvaluation = new PAE bitmap
  
      Tracker.nonreactive =>
        @_renderObject()?.destroy()
        @_physicsObject()?.destroy()
        @_renderObject null
        @_physicsObject null
        
        for shapeClass in @part.constructor.avatarShapes()
          continue unless shape = shapeClass.detectShape pixelArtEvaluation, properties
          @shape shape
          
          @_createObjectsWithShape properties, shape, bitmap
          break
          
  _createObjectsWithShape: (properties, shape, bitmap) ->
    @_renderObject new @constructor.RenderObject @, properties, shape, bitmap
    @_physicsObject new @constructor.PhysicsObject @, properties, shape
    
    @reset()
  
  getRenderObject: -> @_renderObject()
  getPhysicsObject: -> @_physicsObject()
  
  reset: ->
    physicsObject = @_physicsObject()
    physicsObject.reset()
    @_renderObject().updateFromPhysicsObject physicsObject

  class @RenderObject extends AS.RenderObject
    @rotationAxis = new THREE.Vector3 0, -1, 0
  
    constructor: (@avatar, @properties, @shape, @bitmap) ->
      super arguments...
      
      @pinball = @avatar.part.pinball
      
      # Create the physics debug mesh.
      @physicsDebugMaterial = new THREE.MeshLambertMaterial
        color: 0xff0000
        wireframe: true
      
      @physicsDebugGeometry?.dispose()
      @physicsDebugGeometry = @shape.createPhysicsDebugGeometry()

      @physicsDebugMesh = new THREE.Mesh @physicsDebugGeometry, @physicsDebugMaterial
      @physicsDebugMesh.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
      
      @add @physicsDebugMesh
      
      # Create the main mesh and render its texture.
      @material = new THREE.MeshLambertMaterial
        color: 0xffffff
        alphaTest: 0.5
        side: THREE.DoubleSide
        
      pixelSize = Pinball.CameraManager.orthographicPixelSize
      @geometry = new THREE.PlaneGeometry pixelSize * (@bitmap.bounds.width + 2), pixelSize * (@bitmap.bounds.height + 2)
      
      @bitmapPlane = new THREE.Mesh @geometry, @material
      @bitmapPlane.rotation.x = -Math.PI / 2
      @bitmapPlane.scale.x = -1 if @properties.flipped
      @bitmapPlane.receiveShadow = true
      @bitmapPlane.castShadow = true
      @bitmapPlane.layers.set Pinball.RendererManager.RenderLayers.Main
      
      # Offset the mesh so that the shape origin on the bitmap will appear at the render object's position.
      pixelSize = Pinball.CameraManager.orthographicPixelSize
      
      @bitmapPlane.position.x = (@bitmap.bounds.width / 2 - @shape.bitmapOrigin.x) * pixelSize
      @bitmapPlane.position.x *= -1 if @properties.flipped
      @bitmapPlane.position.z = (@bitmap.bounds.height / 2 - @shape.bitmapOrigin.y) * pixelSize
      
      @mesh = new THREE.Object3D
      @mesh.add @bitmapPlane
      @add @mesh
      
      pixelImage = new LOI.Assets.Engine.PixelImage.Bitmap asset: => @bitmap
      
      originalCanvas = pixelImage.getCanvas()
      expandedCanvas = new AM.Canvas originalCanvas.width + 2, originalCanvas.height + 2
      expandedCanvas.context.drawImage originalCanvas, 1, 1
      scaledCanvas = AS.Hqx.scale expandedCanvas, 4, AS.Hqx.Modes.NoBlending, false, true
      
      @material.map = new THREE.CanvasTexture scaledCanvas
      @material.map.minFilter = THREE.NearestFilter
      @material.map.magFilter = THREE.NearestFilter
    
    destroy: ->
      super arguments...
      
      @physicsDebugMaterial.dispose()
      @physicsDebugGeometry.dispose()
      
      @material.dispose()
      @geometry.dispose()
    
    updateFromPhysicsObject: (physicsObject) ->
      physicsObject.motionState.getWorldTransform _transform
      @position.setFromBulletVector3 _transform.getOrigin()
      
      quantizePosition = @pinball.cameraManager().displayType() is Pinball.CameraManager.DisplayTypes.Orthographic and not @pinball.debugPhysics()
      quantizePositionAmount = if quantizePosition then Pinball.CameraManager.orthographicPixelSize else 0
      
      if quantizePositionAmount
        originScreenX = @position.x / quantizePositionAmount
        originScreenY = @position.z / quantizePositionAmount
        
        screenX = originScreenX - @shape.bitmapOrigin.x
        screenY = originScreenY - @shape.bitmapOrigin.y
        
        integerScreenX = Math.round screenX
        integerScreenY = Math.round screenY
        
        @position.x = (integerScreenX + @shape.bitmapOrigin.x) * quantizePositionAmount
        @position.z = (integerScreenY + @shape.bitmapOrigin.y) * quantizePositionAmount
        
      rotation = _transform.getRotation()
      @physicsDebugMesh.quaternion.setFromBulletQuaternion rotation

      unless @shape.fixedBitmapRotation()
        # Rotate the bitmap only around the Y axis.
        _rotation.setFromBulletQuaternion rotation
        _rotationAngles.setFromQuaternion _rotation
        
        # Note: We divide by 1.9 so that when an object is resting at
        # 90 degrees, we don't flip between sides due to instabilities.
        if Math.abs(_rotationAngles.z) > Math.PI / 1.9
          _rotationAngles.z = Math.sign(_rotationAngles.z) * Math.PI
          
        else
          _rotationAngles.z = 0
          
        if Math.abs(_rotationAngles.x) > Math.PI / 1.9
          _rotationAngles.x = Math.sign(_rotationAngles.x) * Math.PI
        
        else
          _rotationAngles.x = 0
        
        @mesh.quaternion.setFromEuler _rotationAngles
    
    renderReflections: (renderer, scene) ->
      unless @cubeCamera
        @cubeCameraRenderTarget = new THREE.WebGLCubeRenderTarget 256,
          format: THREE.RGBAFormat
          type: THREE.FloatType
          stencilBuffer: false

        @cubeCamera = new THREE.CubeCamera 0.001, 10, @cubeCameraRenderTarget

      @visible = false
      @cubeCamera.position.copy @position

      renderer.outputEncoding = THREE.LinearEncoding
      renderer.toneMapping = THREE.NoToneMapping
      renderer.shadowMap.needsUpdate = true
      @cubeCameraRenderTarget.clear renderer
      @cubeCamera.update renderer, scene

      @visible = true

      @material.envMap = @cubeCamera.renderTarget.texture

  class @PhysicsObject extends AR.PhysicsObject
    constructor: (@avatar, @properties, @shape) ->
      super arguments...

      transform = new Ammo.btTransform Ammo.btQuaternion.identity(), Ammo.btVector3.zero()
      @motionState = new Ammo.btDefaultMotionState transform

      @mass = @properties.mass ? 0
      @localInertia = Ammo.btVector3.zero()
      
      @collisionShape = @shape.createCollisionShape()
      margin = @shape.collisionShapeMargin()
      @collisionShape.setMargin margin if margin?
      @collisionShape.calculateLocalInertia @mass, @localInertia

      bodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
      @body = new Ammo.btRigidBody bodyInfo
      
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
