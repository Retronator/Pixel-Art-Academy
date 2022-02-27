AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer
  @LightmapUpdateModes =
    Pause: 'pause'
    Interactive: 'interactive'
    Idle: 'idle'
  
  @lightmapUpdateMaxDuration =
    interactive: 1 / 30
    idle: 1 / 10
  
  @lightmapUpdateCooldown =
    pause: 0
    interactive: 0.1
    
  @lightmapBlendingDuration = 2
  
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

    @bounds = new AE.Rectangle

    @pixelRender = new @constructor.PixelRender @
    @sourceImage = new @constructor.SourceImage @
    @debugCluster = new @constructor.DebugCluster @

    @cameraManager = new @constructor.CameraManager @

    @lightSourcesHelper = @meshCanvas.interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.LightSources

    # Initialize lightmap rendering.
    LOI.Engine.Lightmap.initialize()

    # Add lightmap debug helpers.
    sceneHelper = @meshCanvas.sceneHelper()
    scene = sceneHelper.scene()

    lightmapDebugSphereMaterial = new THREE.MeshBasicMaterial
      color: 0xffffff
      envMap: LOI.Engine.Lightmap.Probe.cubeCamera.renderTarget.texture

    lightmapDebugSphere = new THREE.Mesh new THREE.SphereBufferGeometry(0.5, 32, 32), lightmapDebugSphereMaterial
    lightmapDebugSphere.layers.set LOI.Assets.MeshEditor.RenderLayers.DebugIndirect
    scene.add lightmapDebugSphere

    lightmapDebugProbeOctahedronMapMaterial = new THREE.MeshBasicMaterial
      color: 0xffffff
      map: LOI.Engine.Lightmap.Probe.octahedronMap
      side: THREE.DoubleSide

    lightmapDebugProbeOctahedronMap = new THREE.Mesh new THREE.PlaneBufferGeometry(0.5, 1), lightmapDebugProbeOctahedronMapMaterial
    lightmapDebugProbeOctahedronMap.position.x = 1
    lightmapDebugProbeOctahedronMap.rotation.x = Math.PI
    lightmapDebugProbeOctahedronMap.layers.set LOI.Assets.MeshEditor.RenderLayers.DebugIndirect
    scene.add lightmapDebugProbeOctahedronMap

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
      return unless lightmap = @meshCanvas.meshData()?.lightmap()
      lightmapDebugMaterial.map = lightmap.sourceRenderTarget.texture
      lightmapDebugMaterial.needsUpdate = true

    @meshCanvas.autorun =>
      return unless lightmapSize = @meshCanvas.meshData()?.lightmapAreaProperties.lightmapSize()
      lightmapDebug.scale.y = lightmapSize.height / lightmapSize.width

    @renderSize = new ComputedField =>
      if @meshCanvas.pixelRenderEnabled()
        # We're rendering the main view at the size of the pixel render.
        @pixelRender.bounds.toDimensions()

      else
        # We're rendering at the full renderer size.
        @bounds.toDimensions()

    # Resize the renderer when canvas size changes.
    @meshCanvas.autorun =>
      return unless canvasPixelSize = @meshCanvas.canvasPixelSize()

      console.log "Changing renderer size to", canvasPixelSize if LOI.Assets.debug

      @renderer.setSize canvasPixelSize.width, canvasPixelSize.height, false

      @bounds.width canvasPixelSize.width
      @bounds.height canvasPixelSize.height

    # Handle updating of the lightmap.
    @lightmapUpdateMode = @constructor.LightmapUpdateModes.Pause
    @lightmapUpdateIterations = 1

    @lightmapUpdatePixelsUpdatedCount = 0
    @lightmapUpdateDurationSinceReport = 0

    unless @constructor._lastMouseMoveTime
      @constructor._lastMouseMoveTime = Date.now()

      $(document).on "mousemove.landsofillusions-assets-mesheditor-meshcanvas-renderer, keydown.landsofillusions-assets-mesheditor-meshcanvas-renderer", (event) =>
        @constructor._lastMouseMoveTime = Date.now()
        
        @lightmapUpdateMode = @constructor.LightmapUpdateModes.Interactive
        @lightmapUpdateIterations = 1
        
    @lightmapDurationSinceLastUpdate = 0

    # Reset lightmap iteration when lighting changes.
    @meshCanvas.autorun =>
      # Depend on light direction.
      lightDirectionHelper = @meshCanvas.interface.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.LightDirection
      lightDirectionHelper()
  
      # Depend on light sources.
      @lightSourcesHelper.value()
      
      # Depend on skydome.
      @meshCanvas.sceneHelper().photoSkydomeUrl()
      
      Tracker.nonreactive =>
        @meshCanvas.meshData()?.lightmap()?.resetActiveLevels()
  
    # Prepare rendering statistics.
    @renderTimeFrameCount = 0
    @renderTimeDuration = 0
  
    # Start the reactive redraw routine.
    @meshCanvas.autorun =>
      return unless @reactiveRendering()
    
      # Depend on renderer bounds.
      @bounds.width() and @bounds.height()
    
      # Depend on material changes.
      LOI.Engine.Materials.depend()
    
      @_render()
    
      # Indicate that screen has been re-rendered due to user activity.
      @lightmapUpdateMode = @constructor.LightmapUpdateModes.Pause
      @_lastRenderTime = Date.now()
      
  destroy: ->
    @renderer.dispose()
    $(document).off ".landsofillusions-assets-mesheditor-meshcanvas-renderer"

  draw: (appTime) ->
    reactiveRendering = @reactiveRendering()
  
    lightmapWasUpdated = false
    lightmapEnabled = @lightSourcesHelper.lightmap()
    lightmap = @meshCanvas.meshData()?.lightmap() if lightmapEnabled
    
    if lightmapEnabled and lightmap
      # Lightmap is enabled so we should update some lightmap areas. Calculate how many update iterations we should do.
      if reactiveRendering
        updateStartTime = Date.now()
        
        if @lightmapUpdateMode is @constructor.LightmapUpdateModes.Pause
          # When lightmap updating has paused we're waiting for rendering to stop for the cooldown duration.
          timeSinceLastRender = (updateStartTime - @_lastRenderTime) / 1000

          if timeSinceLastRender > @constructor.lightmapUpdateCooldown.pause
            @lightmapUpdateMode = @constructor.LightmapUpdateModes.Interactive
            @lightmapUpdateIterations = 1

        else if @lightmapUpdateMode is @constructor.LightmapUpdateModes.Interactive
          # When updating in interactive mode, we wait for interactions to stop before going idle.
          timeSinceLastInteraction = (updateStartTime - @constructor._lastMouseMoveTime) / 1000
          if timeSinceLastInteraction > @constructor.lightmapUpdateCooldown.interactive
            @lightmapUpdateMode = @constructor.LightmapUpdateModes.Idle
            
          else
            # If interactive mode can't keep interactive rates even with just 1 render, disable it.
            if @lightmapUpdateIterations is 1 and appTime.elapsedAppTime > @constructor.lightmapUpdateMaxDuration.interactive
              @lightmapUpdateMode = @constructor.LightmapUpdateModes.Pause
            
      else
        # When we're not rendering reactively, we want to render at interactive rates.
        @lightmapUpdateMode = @constructor.LightmapUpdateModes.Interactive
  
      # Only continue if we're not paused.
      unless @lightmapUpdateMode is @constructor.LightmapUpdateModes.Pause
        # Decrease or increase number of update iterations to get closer to the ideal update time.
        if appTime.elapsedAppTime > @constructor.lightmapUpdateMaxDuration[@lightmapUpdateMode]
          @lightmapUpdateIterations = Math.max 1, @lightmapUpdateIterations - 1
  
        else if appTime.elapsedAppTime < @constructor.lightmapUpdateMaxDuration[@lightmapUpdateMode] / 2
          @lightmapUpdateIterations++
  
        # Start rendering loop.
        @_setLinearRendering()
        
        sceneHelper = @meshCanvas.sceneHelper()
        scene = sceneHelper.scene()
        
        for i in [1..@lightmapUpdateIterations]
          updated = lightmap.update @renderer, scene
          
          if updated
            lightmapWasUpdated = true
            
          else
            break
      
        if lightmapWasUpdated
          @lightmapDurationSinceLastUpdate = 0
          
          @lightmapUpdatePixelsUpdatedCount += @lightmapUpdateIterations
          @lightmapUpdateDurationSinceReport += appTime.elapsedAppTime
    
          if @lightmapUpdateDurationSinceReport > 1
            console.log "Lightmap pixels updated per second:", @lightmapUpdatePixelsUpdatedCount if LOI.Assets.debug
            @lightmapUpdateDurationSinceReport = 0
            @lightmapUpdatePixelsUpdatedCount= 0

    # No need to render if we're rendering reactively and lightmap hasn't changed.
    return if reactiveRendering and not lightmapWasUpdated and @lightmapDurationSinceLastUpdate > @constructor.lightmapBlendingDuration
  
    # Blend lightmap towards latest state.
    @_setLinearRendering()
    lightmap?.updateBlending @renderer
    @lightmapDurationSinceLastUpdate += appTime.elapsedAppTime

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
    shadowsEnabled = @meshCanvas.interface.getHelper(LOI.Assets.MeshEditor.Helpers.LightShadowsEnabled)()
    @renderer.shadowMap.enabled = shadowsEnabled
    @renderer.shadowMap.needsUpdate = shadowsEnabled

    @_setToneMappedRendering()

    # Determine which layer to draw.
    paintNormals = @meshCanvas.interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child('paintNormals').value()

    if @meshCanvas.indirectLayerOnly()
      renderLayer = LOI.Engine.RenderLayers.Indirect

    else if paintNormals
      @_setLinearRendering()
      renderLayer = LOI.Assets.MeshEditor.RenderLayers.VisualizeNormals

    else if @meshCanvas.debugMode()
      renderLayer = LOI.Assets.MeshEditor.RenderLayers.Wireframe

    else
      renderLayer = LOI.Engine.RenderLayers.FinalRender

    camera.main.layers.set renderLayer
    camera.main.layers.enable LOI.Assets.MeshEditor.RenderLayers.DebugIndirect if @meshCanvas.debugMode() and @meshCanvas.indirectLayerOnly()

    @renderer.setClearColor 0, 0
    @renderer.setRenderTarget null
    @renderer.clear()
    @renderer.render scene, camera.main

    if @meshCanvas.pixelRenderEnabled()
      # Render main geometry to the low-res render target.
      @_setLinearRendering()
      camera.renderTarget.layers.mask = camera.main.layers.mask
      @renderer.setRenderTarget @pixelRender.renderTarget
      @renderer.setClearColor 0, 0
      @renderer.clear()
      @renderer.render scene, camera.renderTarget

      # Present the low-res render directly to the screen.
      @_setToneMappedRendering()
      pixelRenderScene = @pixelRender.scene.withUpdates()
      @renderer.setRenderTarget null
      @renderer.clearColor()
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
    @renderer.render scene, camera.main

    renderEndTime = performance.now()
    renderTime = renderEndTime - renderStartTime

    @renderTimeFrameCount++
    @renderTimeDuration += renderTime

    if @renderTimeDuration > 1000 or @renderTimeFrameCount > 60
      renderTimeAverage = @renderTimeDuration / @renderTimeFrameCount
      console.log "Current average render time: #{renderTimeAverage}ms." if LOI.Assets.debug

      @renderTimeDuration = 0
      @renderTimeFrameCount = 0
