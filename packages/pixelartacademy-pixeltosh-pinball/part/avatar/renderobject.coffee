AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation
Pinball = PAA.Pixeltosh.Programs.Pinball

_rotationQuaternion = new THREE.Quaternion
_rotationAngles = new THREE.Euler

if Meteor.isClient
  _transform = new Ammo.btTransform

class Pinball.Part.Avatar.RenderObject extends AS.RenderObject
  @rotationAxis = new THREE.Vector3 0, -1, 0
  
  @physicsDebugMaterial = new THREE.MeshStandardMaterial color: 0x202020

  constructor: (@entity, @existingResources) ->
    super arguments...
    
    @ready = new ReactiveField false
    
    constants = @entity.constants()
    
    @perpendicularRotationOrigin = new THREE.Object3D
    @add @perpendicularRotationOrigin
    
    @freeRotationOrigin = new THREE.Object3D
    @add @freeRotationOrigin
    
    # Create the physics debug mesh.
    @autorun (computation) =>
      return unless shape = @entity.shape()
      
      @physicsDebugGeometry?.dispose()
      @physicsDebugGeometry = @existingResources?.physicsDebugGeometry or shape.createPhysicsDebugGeometry()
      
      @physicsDebugMesh?.removeFromParent()
      @physicsDebugMesh = new THREE.Mesh @physicsDebugGeometry, constants.physicsDebugMaterial or @constructor.physicsDebugMaterial
      @physicsDebugMesh.layers.set Pinball.RendererManager.RenderLayers.PhysicsDebug
      @physicsDebugMesh.receiveShadow = true
      @physicsDebugMesh.castShadow = true
      
      @freeRotationOrigin.add @physicsDebugMesh
    
    if @entity.constants().hidden
      @ready true
      return

    # Create the main mesh.
    @flipped = new ComputedField => @entity.shapeProperties().flipped
    
    @autorun (computation) =>
      return unless shape = @entity.shape()
      bitmap = @entity.bitmap()
      texture = @entity.texture()
      
      if @existingResources?.material
        @material = @existingResources.material
        
      else
        @material?.dispose()
        @material = new THREE.MeshBasicMaterial
          color: 0xffffff
          alphaTest: 0.5
          side: THREE.DoubleSide
          map: texture
          
      pixelSize = Pinball.CameraManager.orthographicPixelSize

      # Note: Our texture has an extra padding of 1px around the bitmap so we need the plane to be 2px larger.
      if @existingResources?.geometry
        @geometry = @existingResources?.geometry
        
      else
        @geometry?.dispose()
        
        switch shape.meshStyle()
          when Pinball.Part.Avatar.Shape.MeshStyles.Plane
            @geometry = new THREE.PlaneGeometry pixelSize * (bitmap.bounds.width + 2), pixelSize * (bitmap.bounds.height + 2)
            
          when Pinball.Part.Avatar.Shape.MeshStyles.Extrusion
            @geometry = @constructor._createExtrusionGeometry texture, shape.height
      
      flipped = @flipped()
      
      @bitmapMesh = new THREE.Mesh @geometry, @material
      @bitmapMesh.rotation.x = -Math.PI / 2
      @bitmapMesh.scale.x = -1 if flipped
      @bitmapMesh.receiveShadow = true
      @bitmapMesh.castShadow = true
      @bitmapMesh.layers.set Pinball.RendererManager.RenderLayers.Main
      
      # Offset the mesh so that the shape origin on the bitmap will appear at the render object's position.
      @bitmapMesh.position.x = (bitmap.bounds.width / 2 - shape.bitmapOrigin.x) * pixelSize
      @bitmapMesh.position.x *= -1 if flipped
      @bitmapMesh.position.z = (bitmap.bounds.height / 2 - shape.bitmapOrigin.y) * pixelSize
      
      @mesh?.removeFromParent()
      @mesh = new THREE.Object3D
      @mesh.add @bitmapMesh
      
      switch shape.rotationStyle()
        when Pinball.Part.Avatar.Shape.RotationStyles.Fixed
          @add @mesh
        when Pinball.Part.Avatar.Shape.RotationStyles.Perpendicular
          @perpendicularRotationOrigin.add @mesh
        when Pinball.Part.Avatar.Shape.RotationStyles.Free
          @freeRotationOrigin.add @mesh
      
      @ready true
  
  destroy: ->
    super arguments...
    
    return if @existingResources

    @physicsDebugGeometry.dispose()
    @material.dispose()
    @geometry.dispose()
    
  clone: ->
    new @constructor @part, @
    
  getRotationQuaternionForSnapping: ->
    return @quaternion unless shape = @entity.shape()
    
    switch shape.rotationStyle()
      when Pinball.Part.Avatar.Shape.RotationStyles.Fixed
        @quaternion
      when Pinball.Part.Avatar.Shape.RotationStyles.Perpendicular
        @perpendicularRotationOrigin.quaternion
      when Pinball.Part.Avatar.Shape.RotationStyles.Free
        @freeRotationOrigin.quaternion
    
  updateFromPhysicsObject: (physicsObject) ->
    physicsObject.motionState.getWorldTransform _transform
    @position.setFromBulletVector3 _transform.getOrigin()
    
    rotationQuaternion = _transform.getRotation()
    @freeRotationOrigin.quaternion.setFromBulletQuaternion rotationQuaternion
    
    # For the perpendicular rotation origin, rotate the object only around the Y axis.
    _rotationQuaternion.setFromBulletQuaternion rotationQuaternion
    _rotationAngles.setFromQuaternion _rotationQuaternion
    
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
    
    @perpendicularRotationOrigin.quaternion.setFromEuler _rotationAngles
    
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
