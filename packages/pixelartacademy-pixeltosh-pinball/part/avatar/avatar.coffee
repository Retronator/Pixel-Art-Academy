AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Part.Avatar extends LOI.Adventure.Thing.Avatar
  constructor: (part, @properties = {}) ->
    super part.constructor

    @part = part
    
    @_renderObject = new ReactiveField null
    @_physicsObject = new ReactiveField null
    
  destroy: ->
    super arguments...

    @_renderObject()?.destroy()
    @_physicsObject()?.destroy()
  
  # Note: We initialize the avatar separately since the construction happens
  # already in the thing's constructor and we don't have any extra fields available.
  initialize: (partData) ->
    @part.autorun =>
      # Analyze the bitmap to determine the shape of the part.
      return unless bitmap = @part.bitmap()
      pixelArtEvaluation = new PAE bitmap
  
      Tracker.nonreactive =>
        @_renderObject()?.destroy()
        @_physicsObject()?.destroy()
        
        for shapeClass in @part.constructor.avatarShapes()
          if shape = shapeClass.detectShape pixelArtEvaluation, @properties
            @_renderObject new @constructor.RenderObject @, shape, bitmap
            
            physicsObject = new @constructor.PhysicsObject @, shape
            physicsObject.setDesignPosition partData.position if partData.position
            physicsObject.setRotation partData.rotationQuaternion if partData.rotationQuaternion
            @_physicsObject physicsObject
  
  getRenderObject: -> @_renderObject()
  getPhysicsObject: -> @_physicsObject()

  class @RenderObject extends AS.RenderObject
    constructor: (@avatar, @shape, @bitmap) ->
      super arguments...
      
      # Create the physics debug mesh.
      @physicsDebugMaterial = new THREE.MeshLambertMaterial
        color: 0xff0000
        wireframe: true
      
      @physicsDebugGeometry?.dispose()
      @physicsDebugGeometry = @shape.createPhysicsDebugGeometry()

      @remove @physicsDebugMesh if @physicsDebugMesh

      @physicsDebugMesh = new THREE.Mesh @physicsDebugGeometry, @physicsDebugMaterial
      @physicsDebugMesh.receiveShadow = true
      @physicsDebugMesh.castShadow = true
      @physicsDebugMesh.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
      
      @add @physicsDebugMesh
      
      # Create the main mesh and render its texture.
      @material = new THREE.MeshLambertMaterial
        color: 0xffffff
        alphaTest: 0.5
        
      pixelSize = Pinball.CameraManager.orthographicPixelSize
      @geometry = new THREE.PlaneGeometry pixelSize * (@bitmap.bounds.width + 2), pixelSize * (@bitmap.bounds.height + 2)
      
      @mesh = new THREE.Mesh @geometry, @material
      @mesh.rotation.x = -Math.PI / 2
      @mesh.receiveShadow = true
      @mesh.castShadow = true
      @mesh.layers.set Pinball.RendererManager.RenderLayers.Main
      
      # Offset the mesh so that the shape origin on the bitmap will appear at the render object's position.
      pixelSize = Pinball.CameraManager.orthographicPixelSize
      @mesh.position.x = (@bitmap.bounds.width / 2 - @shape.bitmapOrigin.x) * pixelSize
      @mesh.position.z = (@bitmap.bounds.height / 2 - @shape.bitmapOrigin.y) * pixelSize
      
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
    
    updateFromPhysics: (transform, quantizePositionAmount) ->
      @position.setFromBulletVector3 transform.getOrigin()
      
      if quantizePositionAmount
        originScreenX = @position.x / quantizePositionAmount
        originScreenY = @position.z / quantizePositionAmount
        
        screenX = originScreenX - @shape.bitmapOrigin.x
        screenY = originScreenY - @shape.bitmapOrigin.y
        
        integerScreenX = Math.round screenX
        integerScreenY = Math.round screenY
        
        @position.x = (integerScreenX + @shape.bitmapOrigin.x) * quantizePositionAmount
        @position.z = (integerScreenY + @shape.bitmapOrigin.y) * quantizePositionAmount
        
      @physicsDebugMesh.quaternion.setFromBulletQuaternion transform.getRotation()
    
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
    constructor: (@avatar, @shape) ->
      super arguments...

      transform = new Ammo.btTransform Ammo.btQuaternion.identity, new Ammo.btVector3
      @motionState = new Ammo.btDefaultMotionState transform

      @mass = @avatar.properties.mass ? 1
      @localInertia = new Ammo.btVector3 0, 0, 0
      
      @collisionShape = @shape.createCollisionShape()
      margin = @shape.collisionShapeMargin()
      @collisionShape.setMargin margin if margin?
      @collisionShape.calculateLocalInertia @mass, @localInertia

      bodyInfo = new Ammo.btRigidBodyConstructionInfo @mass, @motionState, @collisionShape, @localInertia
      @body = new Ammo.btRigidBody bodyInfo

      # Default body will be elastic and frictionless.
      @body.setRestitution @avatar.properties.restitution ? 1
      @body.setFriction @avatar.properties.friction ? 0
      @body.setRollingFriction @avatar.properties.rollingFriction ? 0
      
    setDesignPosition: (designPosition) ->
      @setPosition
        x: designPosition.x
        y: @shape.yPosition()
        z: designPosition.y
