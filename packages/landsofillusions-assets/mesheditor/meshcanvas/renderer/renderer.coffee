AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer
  constructor: (@meshCanvas) ->
    @reactiveRendering = new ReactiveField true

    @renderer = new THREE.WebGLRenderer
      powerPreference: 'high-performance'
      alpha: true
      physicallyCorrectLights: true
      canvas: @meshCanvas.canvas()

    @renderer.shadowMap.autoUpdate = false
    @renderer.shadowMap.type = THREE.BasicShadowMap

    @renderer.autoClearColor = false
    @renderer.autoClearDepth = false

    @bounds = new AE.Rectangle()

    @pixelRender = new @constructor.PixelRender @
    @sourceImage = new @constructor.SourceImage @
    @debugCluster = new @constructor.DebugCluster @

    @cameraManager = new @constructor.CameraManager @

    # Initialize radiance transfer rendering and add enable to render hidden clusters during radiance update.
    LOI.Engine.RadianceState.initialize()
    LOI.Engine.IlluminationState.initialize()

    LOI.Engine.RadianceState.Probe.cubeCamera.layers.enable 3

    # Add radiance debug helpers.
    sceneHelper = @meshCanvas.sceneHelper()
    scene = sceneHelper.scene()

    radianceDebugSphereMaterial = new THREE.MeshBasicMaterial
      color: 0xffffff
      envMap: LOI.Engine.RadianceState.Probe.cubeCamera.renderTarget.texture

    radianceDebugSphere = new THREE.Mesh new THREE.SphereBufferGeometry(0.5, 32, 32), radianceDebugSphereMaterial
    radianceDebugSphere.layers.set LOI.Assets.MeshEditor.RenderLayers.DebugIndirect
    scene.add radianceDebugSphere

    radianceDebugProbeOctahedronMapMaterial = new THREE.MeshBasicMaterial
      color: 0xffffff
      map: LOI.Engine.RadianceState.Probe.octahedronMap
      side: THREE.DoubleSide

    radianceDebugProbeOctahedronMap = new THREE.Mesh new THREE.PlaneBufferGeometry(0.5, 1), radianceDebugProbeOctahedronMapMaterial
    radianceDebugProbeOctahedronMap.position.x = 1
    radianceDebugProbeOctahedronMap.rotation.x = Math.PI
    radianceDebugProbeOctahedronMap.layers.set LOI.Assets.MeshEditor.RenderLayers.DebugIndirect
    scene.add radianceDebugProbeOctahedronMap

    lightmapDebugMaterial = new THREE.MeshBasicMaterial
      color: 0xffffff
      map: null
      side: THREE.DoubleSide
      transparent: true

    lightmapDebug = new THREE.Mesh new THREE.PlaneBufferGeometry(1, 1), lightmapDebugMaterial
    lightmapDebug.position.x = 2
    lightmapDebug.rotation.x = Math.PI
    lightmapDebug.layers.set LOI.Assets.MeshEditor.RenderLayers.DebugIndirect
    scene.add lightmapDebug

    @meshCanvas.autorun =>
      return unless illuminationState = @meshCanvas.mesh()?.illuminationState()
      lightmapDebugMaterial.map = illuminationState.lightmap.texture

    @meshCanvas.autorun =>
      return unless lightmapSize = @meshCanvas.meshData()?.lightmapAreaProperties.lightmapSize()
      lightmapDebug.scale.y = lightmapSize.height / lightmapSize.width

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

      # Indicate that screen has been re-rendered due to user activity.
      @_lastRenderTime = Date.now()

    # Handle updating radiance state.
    @radianceUpdateMaxDuration =
      realtime: 0
      interactive: 1 / 30
      idle: 1 / 10

    @radianceUpdateCooldown =
      realtime: 0.5
      interactive: 0.5

    @_lastRenderTime = Date.now()

    @globalRadianceUpdateTime = 0
    @globalRadianceUpdatePixelsUpdatedCount = 0
    @durationSinceLastRadianceUpdateReport = 0

    @renderTimeFrameCount = 0
    @renderTimeDuration = 0

    unless @constructor._lastMouseMoveTime
      @constructor._lastMouseMoveTime = Date.now()

      $(document).on "mousemove.landsofillusions-assets-mesheditor-meshcanvas-renderer", (event) =>
        @constructor._lastMouseMoveTime = Date.now()

  destroy: ->
    @renderer.dispose()

  draw: (appTime) ->
    radianceWasUpdated = false
    totalUpdatedCount = 0

    lightmapEnabled = @meshCanvas.lightmapEnabled()
    illuminationState = @meshCanvas.mesh().illuminationState() if lightmapEnabled

    if lightmapEnabled and illuminationState
      # We're doing PBR or GI so we should update some of the radiance
      # states. Calculate how much time we can we spend for this.
      updateStartTime = Date.now()
      timeSinceLastRender = (updateStartTime - @_lastRenderTime) / 1000
      timeSinceLastInteraction = (updateStartTime - @constructor._lastMouseMoveTime) / 1000

      updateDuration = @radianceUpdateMaxDuration.idle

      if timeSinceLastInteraction < @radianceUpdateCooldown.interactive
        updateDuration = @radianceUpdateMaxDuration.interactive

      if timeSinceLastRender < 2 * @radianceUpdateCooldown.realtime
        updateDuration = @radianceUpdateMaxDuration.realtime

      if updateDuration
        highPrecisionUpdateEndTime = performance.now() + updateDuration * 1000

        # Start rendering loop.
        @_setLinearRendering()
        @renderer.shadowMap.enabled = false

        radianceUpdateStartTime = performance.now()

        while performance.now() < highPrecisionUpdateEndTime
          illuminationState.update @renderer, scene
          radianceWasUpdated = true
          totalUpdatedCount++

        radianceUpdateEndTime = performance.now()
        radianceUpdateTime = radianceUpdateEndTime - radianceUpdateStartTime

        @globalRadianceUpdateTime += radianceUpdateTime
        @globalRadianceUpdatePixelsUpdatedCount += totalUpdatedCount

        @durationSinceLastRadianceUpdateReport += radianceUpdateTime / 1000

      if @durationSinceLastRadianceUpdateReport > 1
        @durationSinceLastRadianceUpdateReport--
        globalAverage = @globalRadianceUpdateTime / @globalRadianceUpdatePixelsUpdatedCount
        console.log "Radiance update average time per pixel: #{globalAverage}ms."

        # Reset average every 3 seconds.
        if @globalRadianceUpdateTime > 3000
          @globalRadianceUpdateTime = 0
          @globalRadianceUpdatePixelsUpdatedCount = 0

    # No need to render if we're rendering reactively and radiance hasn't changed.
    return if @reactiveRendering() and not radianceWasUpdated

    unless radianceWasUpdated
      # Indicate that render has executed due to real-time rendering.
      @_lastRenderTime = Date.now()

    @_render()

  _setLinearRendering: ->
    @renderer.outputEncoding = THREE.LinearEncoding
    @renderer.toneMapping = THREE.NoToneMapping

  _setToneMappedRendering: ->
    @renderer.outputEncoding = THREE.sRGBEncoding
    @renderer.toneMapping = THREE.ACESFilmicToneMapping

    exposureValue = @meshCanvas.interface.getHelperForActiveFile LOI.Assets.Editor.Helpers.ExposureValue
    @renderer.toneMappingExposure = exposureValue.exposure()

  _render: ->
    renderStartTime = performance.now()

    sceneHelper = @meshCanvas.sceneHelper()
    scene = sceneHelper.scene.withUpdates()

    camera = @cameraManager.camera.withUpdates()

    # Enable/disable updating of shadow map.
    shadowsEnabled = @meshCanvas.interface.getHelperForActiveFile(LOI.Assets.MeshEditor.Helpers.LightShadowsEnabled)()
    @renderer.shadowMap.enabled = shadowsEnabled
    @renderer.shadowMap.needsUpdate = shadowsEnabled

    @_setToneMappedRendering()
    camera.main.layers.set LOI.Engine.RenderLayers.FinalRender
    @renderer.setClearColor 0, 0
    @renderer.setRenderTarget null
    @renderer.clear()
    @renderer.render scene, camera.main

    if @meshCanvas.pixelRenderEnabled()
      # Render main geometry to the low-res render target.
      @_setLinearRendering()
      @renderer.setRenderTarget @pixelRender.renderTarget
      @renderer.setClearColor 0, 0
      @renderer.clear()
      @renderer.render scene, camera.renderTarget

      # Present the low-res render directly to the screen.
      @_setToneMappedRendering()
      pixelRenderScene = @pixelRender.scene.withUpdates()
      @renderer.setRenderTarget null
      @renderer.render pixelRenderScene, camera.pixelRender

    @_setLinearRendering()

    if @meshCanvas.sourceImageEnabled() and @meshCanvas.activePicture()?.bounds()
      @sourceImage.image.material.texturesDepenency.depend()
      uniforms = @sourceImage.image.material.uniforms

      if uniforms.map.value and uniforms.normalMap.value
        # Render the source image to the main scene.
        sourceImageScene = @sourceImage.scene.withUpdates()
        @renderer.render sourceImageScene, camera.pixelRender

    # Render helpers that overlay the geometry.
    camera.main.layers.set LOI.Assets.MeshEditor.RenderLayers.OverlayHelpers
    camera.main.layers.enable LOI.Assets.MeshEditor.RenderLayers.OverlayDebug if @meshCanvas.debugMode()
    @renderer.render scene, camera.main

    renderEndTime = performance.now()
    renderTime = renderEndTime - renderStartTime

    @renderTimeFrameCount++
    @renderTimeDuration += renderTime

    if @renderTimeDuration > 1000 or @renderTimeFrameCount > 60
      renderTimeAverage = @renderTimeDuration / @renderTimeFrameCount
      console.log "Current average render time: #{renderTimeAverage}ms."

      @renderTimeDuration = 0
      @renderTimeFrameCount = 0
