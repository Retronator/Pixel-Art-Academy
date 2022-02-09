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

    # Setup the environment skydomes.
    photoSkydomeUpdatedDependency = new Tracker.Dependency

    @skydome =
      procedural: new LOI.Engine.Skydome.Procedural
        addDirectionalLight: true
        directionalLightDistance: 100
        generateEnvironmentMap: true
        intensityFactors:
          star: 20
          scattering: 0.0013

      photo: new LOI.Engine.Skydome.Photo
        generateEnvironmentMap: true
        onLoaded: =>
          photoSkydomeUpdatedDependency.changed()

    scene.add @skydome.procedural
    scene.add @skydome.photo

    @skydome.photo.rotation.y = Math.PI / 2

    directionalLight = @skydome.procedural.directionalLight

    directionalLight.castShadow = true
    d = 10
    
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

    # Move light around.
    @lightDirectionHelper = @interface.getHelperForFile LOI.Assets.SpriteEditor.Helpers.LightDirection, @fileId

    @meshCanvas = new ComputedField =>
      @interface.getEditorViewForFile(@fileId)?.getActiveEditor()
    ,
      (a, b) => a is b

    @lightSourcesHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.LightSources

    @autorun (computation) =>
      # Set the new position.
      lightDirection = @lightDirectionHelper()
      directionalLight.position.copy lightDirection.clone().multiplyScalar -100

      @scene.updated()

    # Update environment.
    @photoSkydomeUrl = new ComputedField =>
      return unless meshData = @meshCanvas()?.meshData()

      activeEnvironment = _.find meshData.environments, (environment) -> environment.active
      activeEnvironment?.image.url

    @autorun (computation) =>
      photoSkydomeUrl = @photoSkydomeUrl()

      if photoSkydomeUrl
        @skydome.photo.loadFromUrl photoSkydomeUrl

      # Enable the correct skydome. We need to have a proper boolean so
      # that the visible property below also has an explicit false value.
      @skydome.procedural.visible = not photoSkydomeUrl
      @skydome.photo.visible = photoSkydomeUrl?

      # See if the sphere in the final render should be visible.
      skydomeVisible = @meshCanvas()?.skydomeVisible()
      @skydome.procedural.sphere.visible = skydomeVisible
      @skydome.photo.sphere.visible = skydomeVisible

      @scene.updated()

    @autorun (computation) =>
      return unless meshCanvas = @meshCanvas()
      return unless meshCanvas.isRendered()

      if @photoSkydomeUrl()
        photoSkydomeUpdatedDependency.depend()
        @skydome.photo.updateTexture meshCanvas.renderer.renderer
        scene.environment = @skydome.photo.environmentMap

      else
        lightDirection = @lightDirectionHelper()
        @skydome.procedural.updateTexture meshCanvas.renderer.renderer, lightDirection
        scene.environment = @skydome.procedural.environmentMap

      @scene.updated()

    # Apply uniforms to new objects when they get added.
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

  destroy: ->
    super arguments...

    @meshCanvas.stop()
    @photoSkydomeUrl.stop()

    @skydome.procedural.destroy()
    @skydome.photo.destroy()

  getUniforms: ->
    return unless meshCanvas = @meshCanvas()

    # Mesh canvas needs to be rendered for the renderer to be available.
    return unless meshCanvas.isRendered()
    return unless renderSize = meshCanvas.renderer.renderSize()

    if cameraAngle = meshCanvas.meshData()?.cameraAngles.get 0
      defaultViewport = left: -1, right: 1, bottom: -1, top: 1
      cameraAngleMatrix = new THREE.Matrix4
      cameraAngle.getProjectionMatrixForViewport defaultViewport, cameraAngleMatrix
      cameraAngleMatrix.multiply cameraAngle.viewMatrix

    if currentCameraAngle = meshCanvas.cameraAngle()
      cameraParallelProjection = not currentCameraAngle.picturePlaneDistance?

      if cameraParallelProjection
        cameraDirection = currentCameraAngle.getCameraDirection()

    renderSize: new THREE.Vector2 renderSize.width, renderSize.height
    cameraAngleMatrix: cameraAngleMatrix or new THREE.Matrix4
    cameraParallelProjection: cameraParallelProjection or false
    cameraDirection: cameraDirection or new THREE.Vector3
    preprocessingMap: meshCanvas.renderer.preprocessingRenderTarget.texture
    colorQuantizationFactor: (LOI.settings.graphics.colorQuantizationLevels.value() or 1) - 1

  addedSceneObjects: ->
    @sceneObjectsAddedDependency.changed()
    @scene.updated()

  _applyUniformsToMaterial: (uniforms, material) ->
    for uniform, value of uniforms
      if material.uniforms[uniform]
        material.uniforms[uniform].value = value
        material.needsUpdate = true
