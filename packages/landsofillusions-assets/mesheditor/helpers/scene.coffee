AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.Scene extends FM.Helper
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.Scene'
  @initialize()

  constructor: ->
    super arguments...

    scene = new THREE.Scene()
    scene.manager = @
    @scene = new AE.ReactiveWrapper scene

    @sceneObjectsAddedDependency = new Tracker.Dependency

    @directionalLights = new ReactiveField []

    # Setup default lights.
    ambientLight = new THREE.AmbientLight 0xffffff, 0.4
    scene.add ambientLight

    directionalLight = new THREE.DirectionalLight 0xffffff, 0.6

    directionalLight.castShadow = true
    d = 20
    
    shadow = directionalLight.shadow
    shadow.camera.left = -d
    shadow.camera.right = d
    shadow.camera.top = d
    shadow.camera.bottom = -d
    shadow.camera.near = 50
    shadow.camera.far = 200
    shadow.mapSize.width = 4096
    shadow.mapSize.height = 4096
    shadow.bias = 0

    for extraShadowMap in ['opaqueMap', 'colorMap']
      shadow[extraShadowMap] = new THREE.WebGLRenderTarget shadow.mapSize.x, shadow.mapSize.y,
        minFilter: THREE.NearestFilter
        magFilter: THREE.NearestFilter

    scene.add directionalLight
    @directionalLights [directionalLight]

    # Move light around.
    @lightDirectionHelper = @interface.getHelperForFile LOI.Assets.SpriteEditor.Helpers.LightDirection, @fileId

    @autorun (computation) =>
      # Set the new position.
      lightDirection = @lightDirectionHelper()
      directionalLight.position.copy lightDirection.clone().multiplyScalar -100

      # Update the shadow camera matrix since it needs to be updated before the shadow casting pass.
      directionalLight.shadow.camera.position.copy directionalLight.position

      lookTarget = new THREE.Vector3().setFromMatrixPosition directionalLight.target.matrixWorld
      directionalLight.shadow.camera.lookAt lookTarget
      directionalLight.shadow.camera.updateMatrixWorld()

      @scene.updated()

    # Apply uniforms to new objects when they get added.
    @meshCanvas = new ComputedField =>
      @interface.getEditorForActiveFile()
    ,
      (a, b) => a is b

    @autorun (computation) =>
      return unless uniforms = @getUniforms()
      @sceneObjectsAddedDependency.depend()

      scene.traverse (object) =>
        return unless object.mainMaterial?.uniforms and not object.mainMaterial.uniformsInitialized
        object.mainMaterial.uniformsInitialized = true

        @_applyUniformsToMaterial uniforms, object.mainMaterial

    # Apply uniforms to all objects when uniforms change.
    @autorun (computation) =>
      return unless uniforms = @getUniforms()

      scene.traverse (object) =>
        return unless object.mainMaterial?.uniforms

        @_applyUniformsToMaterial uniforms, object.mainMaterial

      @scene.updated()

  getUniforms: ->
    return unless meshCanvas = @meshCanvas()

    # Mesh canvas needs to be rendered for the renderer to be available.
    return unless meshCanvas.isRendered()
    return unless renderSize = meshCanvas.renderer.renderSize()

    directionalLights = @directionalLights()

    if cameraAngle = meshCanvas.meshData()?.cameraAngles.get 0
      defaultViewport = left: -1, right: 1, bottom: -1, top: 1
      cameraAngleMatrix = new THREE.Matrix4
      cameraAngle.getProjectionMatrixForViewport defaultViewport, cameraAngleMatrix
      cameraAngleMatrix.multiply cameraAngle.worldMatrixInverse

    renderSize: new THREE.Vector2 renderSize.width, renderSize.height
    cameraAngleMatrix: cameraAngleMatrix or new THREE.Matrix4
    directionalOpaqueShadowMap: (directionalLight.shadow.opaqueMap.texture for directionalLight in directionalLights)
    directionalShadowColorMap: (directionalLight.shadow.colorMap.texture for directionalLight in directionalLights)
    preprocessingMap: meshCanvas.renderer.preprocessingRenderTarget.texture

  addedSceneObjects: ->
    @sceneObjectsAddedDependency.changed()
    @scene.updated()

  _applyUniformsToMaterial: (uniforms, material) ->
    for uniform, value of uniforms
      if material.uniforms[uniform]
        material.uniforms[uniform].value = value
        material.needsUpdate = true
