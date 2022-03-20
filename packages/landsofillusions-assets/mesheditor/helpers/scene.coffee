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

    @lightSourcesHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.LightSources
    @uniformClustersHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.UniformClusters
    @restrictColorsHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.RestrictColors

    @lightVisibilityHelper = @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.LightVisibility, @fileId

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

    @environmentMap = new ReactiveField null

    @autorun (computation) =>
      environmentMapsEnabled = @lightSourcesHelper.environmentMaps()
      scene.environment = if environmentMapsEnabled then @environmentMap() else null

      @scene.updated()

    directionalLight = @skydome.procedural.directionalLight

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

    # Move light around.
    @lightDirectionHelper = @interface.getHelperForFile LOI.Assets.SpriteEditor.Helpers.LightDirection, @fileId

    @meshCanvas = new ComputedField =>
      @interface.getEditorViewForFile(@fileId)?.getActiveEditor()
    ,
      (a, b) => a is b

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
        # Load the photo skydome.
        @skydome.photo.loadFromUrl photoSkydomeUrl

      # Enable the correct skydome. We need to have a proper boolean so
      # that the visible property below also has an explicit false value.
      @skydome.procedural.visible = not photoSkydomeUrl
      @skydome.photo.visible = photoSkydomeUrl?

      @scene.updated()

    @autorun (computation) =>
      # Set if the sphere in the final render should be visible (the indirect sphere needs to be visible in any case).
      skydomeVisible = @meshCanvas()?.skydomeVisible()
      @skydome.procedural.sphere.visible = skydomeVisible
      @skydome.photo.sphere.visible = skydomeVisible

      @scene.updated()

    @autorun (computation) =>
      # Enable direct light in the skydome if geometric lights are enabled.
      lightsEnabled = @lightSourcesHelper.lights()
      @skydome.procedural.directionalLight.visible = lightsEnabled

      @scene.updated()

    @autorun (computation) =>
      return unless meshCanvas = @meshCanvas()
      return unless meshCanvas.isRendered()

      if @photoSkydomeUrl()
        photoSkydomeUpdatedDependency.depend()
        @skydome.photo.updateTexture meshCanvas.renderer.renderer
        @environmentMap @skydome.photo.environmentMap

      else
        lightDirection = @lightDirectionHelper()
        @skydome.procedural.updateTexture meshCanvas.renderer.renderer, lightDirection
        @environmentMap @skydome.procedural.environmentMap

      @scene.updated()
  
    @visualizeNormals = new ComputedField =>
      return unless meshCanvas = @meshCanvas()
      meshCanvas.normalsOnly()
  
    @visualizeLightmap = new ComputedField =>
      return unless meshCanvas = @meshCanvas()
      meshCanvas.lightmapOnly()

    # Apply uniforms to new objects when they get added.
    @autorun (computation) =>
      return unless uniforms = @getUniforms()
      @sceneObjectsAddedDependency.depend()

      scene.traverse (object) =>
        return unless object.material?.uniforms and not object.material.uniformsInitialized
        object.material.uniformsInitialized = true

        @_applyUniformsToObject uniforms, object

    # Apply uniforms to all objects when uniforms change.
    @autorun (computation) =>
      return unless uniforms = @getUniforms()

      scene.traverse (object) =>
        return unless object.material?.uniforms
  
        @_applyUniformsToObject uniforms, object

      @scene.updated()

  destroy: ->
    super arguments...

    @skydome.procedural.destroy()
    @skydome.photo.destroy()

  getUniforms: ->
    return unless meshCanvas = @meshCanvas()

    # Mesh canvas needs to be rendered for the renderer to be available.
    return unless meshCanvas.isRendered()
    return unless renderSize = meshCanvas.renderer.renderSize()
    return unless meshData = @meshCanvas()?.meshData()

    if cameraAngle = meshData.cameraAngles.get 0
      defaultViewport = left: -1, right: 1, bottom: -1, top: 1
      cameraAngleMatrix = new THREE.Matrix4
      cameraAngle.getProjectionMatrixForViewport defaultViewport, cameraAngleMatrix
      cameraAngleMatrix.multiply cameraAngle.viewMatrix

    if currentCameraAngle = meshCanvas.cameraAngle()
      cameraParallelProjection = not currentCameraAngle.picturePlaneDistance?

      if cameraParallelProjection
        cameraDirection = currentCameraAngle.getCameraDirection()

    lightmapSize = new THREE.Vector2

    if @lightSourcesHelper.lightmap()
      lightmap = meshData.lightmap()

      lightmapSizeData = meshData.lightmapAreaProperties.lightmapSize()
      lightmapSize.set lightmapSizeData.width, lightmapSizeData.height

    indirectUniforms =
      renderSize: new THREE.Vector2 renderSize.width, renderSize.height
      cameraAngleMatrix: cameraAngleMatrix or new THREE.Matrix4
      cameraParallelProjection: cameraParallelProjection or false
      cameraDirection: cameraDirection or new THREE.Vector3
      lightmap: lightmap?.indirectTexture
      lightmapSize: lightmapSize
      envMap: if @lightSourcesHelper.environmentMaps() then @environmentMap() else null
      
    mainUniforms = _.defaults
      lightVisibility: @lightVisibilityHelper.toObject()
      uniformClusters: @uniformClustersHelper.toObject()
      restrictColors: @restrictColorsHelper.toObject()
      visualizeNormals: @visualizeNormals() or false
      visualizeLightmap: @visualizeLightmap() or false
      lightmap: lightmap?.texture
    ,
      indirectUniforms
    
    main: mainUniforms
    indirect: indirectUniforms

  addedSceneObjects: ->
    @sceneObjectsAddedDependency.changed()
    @scene.updated()

  _applyUniformsToObject: (uniforms, object) ->
    # Choose main or indirect uniforms.
    uniforms = if object.layers.isEnabled LOI.Engine.RenderLayers.Indirect then uniforms.indirect else uniforms.main
    material = object.material
    
    for uniform, value of uniforms
      if material.uniforms[uniform]
        material.uniforms[uniform].value = value

        # Maps need to be also added on the material itself for defines to kick in.
        material[uniform] = value if _.endsWith uniform, 'Map'

        material.needsUpdate = true
