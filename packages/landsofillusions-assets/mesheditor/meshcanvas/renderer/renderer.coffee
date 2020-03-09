AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer
  constructor: (@meshCanvas) ->
    @reactiveRendering = new ReactiveField true

    @renderer = new THREE.WebGLRenderer
      canvas: @meshCanvas.canvas()
      context: @meshCanvas.context()
      alpha: true

    @renderer.shadowMap.autoUpdate = false
    @renderer.shadowMap.type = THREE.BasicShadowMap

    @renderer.autoClearColor = false
    @renderer.autoClearDepth = false

    @bounds = new AE.Rectangle()
    
    @pixelRender = new @constructor.PixelRender @
    @sourceImage = new @constructor.SourceImage @

    @cameraManager = new @constructor.CameraManager @

    @renderSize = new ComputedField =>
      if @meshCanvas.pixelRenderEnabled()
        # We're rendering the main view at the size of the pixel render.
        @pixelRender.size()

      else
        # We're rendering at the full renderer size.
        @bounds.toDimensions()

    @preprocessingRenderTarget = new THREE.WebGLRenderTarget 16, 16,
      minFilter: THREE.NearestFilter
      magFilter: THREE.NearestFilter

    # Resize the preprocessing render target when render size changes.
    @meshCanvas.autorun =>
      return unless renderSize = @renderSize()
      @preprocessingRenderTarget.setSize renderSize.width, renderSize.height

    # Resize the renderer when canvas size changes.
    @meshCanvas.autorun =>
      return unless canvasPixelSize = @meshCanvas.canvasPixelSize()

      console.log "Changing renderer size to", canvasPixelSize if LOI.Assets.debug

      @renderer.setSize canvasPixelSize.width, canvasPixelSize.height

      @bounds.width canvasPixelSize.width
      @bounds.height canvasPixelSize.height

    # Start the reactive redraw routine.
    @meshCanvas.autorun =>
      return unless @reactiveRendering()

      # Depend on renderer bounds.
      @bounds.width() and @bounds.height()

      # Depend on material changes.
      LOI.Engine.Materials.depend()

      @_render()

  draw: (appTime) ->
    return if @reactiveRendering()

    @_render()

  _render: ->
    sceneHelper = @meshCanvas.sceneHelper()
    scene = sceneHelper.scene.withUpdates()

    camera = @cameraManager.camera.withUpdates()

    # Set up main geometry.
    camera.main.layers.set 0
    shadowsEnabled = @meshCanvas.interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.ShadowsEnabled, @meshCanvas.meshId()

    # Render the preprocessing step. First set the preprocessing material on all meshes.
    scene.traverse (object) =>
      return unless object.isMesh

      # Remember if the object is supposed to be visible since we'll hide it in some of the rendering steps.
      object.wasVisible = object.visible

      if object.preprocessingMaterial
        object.material = object.preprocessingMaterial

      else
        object.visible = false

    @renderer.setClearColor 0x000000, 1
    @renderer.setRenderTarget @preprocessingRenderTarget
    @renderer.clear()
    @renderer.render scene, camera.main

    if shadowsEnabled()
      # Render the color shadow maps. First set the shadow color material on all meshes.
      scene.traverse (object) =>
        return unless object.isMesh

        if object.shadowColorMaterial
          object.material = object.shadowColorMaterial
          object.visible = object.wasVisible

        else
          object.visible = false

      # Render all lights' shadow color maps.
      for directionalLight in sceneHelper.directionalLights()
        @renderer.setClearColor 0xffff00, 1
        @renderer.setRenderTarget directionalLight.shadow.colorMap
        @renderer.clear()
        @renderer.render scene, directionalLight.shadow.camera

      # Render the opaque shadow maps. We need to set the depth material on all opaque meshes and hide the rest.
      scene.traverse (object) =>
        return unless object.isMesh

        if object.customDepthMaterial
          object.material = object.customDepthMaterial
          object.visible = object.wasVisible and not object.mainMaterial.transparent

        else
          object.visible = false

      # Render all lights' opaque shadow maps.
      for directionalLight in sceneHelper.directionalLights()
        @renderer.setClearColor 0xffffff, 1
        @renderer.setRenderTarget directionalLight.shadow.opaqueMap
        @renderer.clear()
        @renderer.render scene, directionalLight.shadow.camera

    # Reinstate main materials and object visibility.
    scene.traverse (object) =>
      return unless object.isMesh

      object.visible = true if object.wasVisible
      object.material = object.mainMaterial if object.mainMaterial

    # Render main geometry pass that we use for depth and shadows (and color when not showing the render target).
    @renderer.shadowMap.enabled = shadowsEnabled()
    @renderer.shadowMap.needsUpdate = true

    @renderer.setClearColor 0, 0
    @renderer.setRenderTarget null
    @renderer.clear()
    @renderer.render scene, camera.main

    if @meshCanvas.pixelRenderEnabled()
      # Render main geometry to the render target.
      @renderer.setRenderTarget @pixelRender.renderTarget
      @renderer.setClearColor 0, 0
      @renderer.clear()
      @renderer.render scene, camera.renderTarget

      # Render the low-res picture to the main scene.
      pixelRenderScene = @pixelRender.scene.withUpdates()
      @renderer.setRenderTarget null
      @renderer.render pixelRenderScene, camera.pixelRender

    if @meshCanvas.sourceImageEnabled() and @meshCanvas.activePicture()?.bounds()
      @sourceImage.image.material.texturesDepenency.depend()
      uniforms = @sourceImage.image.material.uniforms
      if uniforms.map.value and uniforms.normalMap.value
        # Render the source image to the main scene.
        sourceImageScene = @sourceImage.scene.withUpdates()
        @renderer.render sourceImageScene, camera.pixelRender

    # Render helpers that overlay the geometry.
    camera.main.layers.set 1
    @renderer.render scene, camera.main

    # Render debug visuals.
    if @meshCanvas.debugMode()
      camera.main.layers.set 2
      @renderer.render scene, camera.main

  destroy: ->
    @renderer.dispose()
