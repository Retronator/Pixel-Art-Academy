AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer
  constructor: (@meshCanvas) ->
    @reactiveRendering = new ReactiveField true

    @renderer = new THREE.WebGLRenderer
      canvas: @meshCanvas.canvas()
      context: @meshCanvas.context()

    @renderer.shadowMap.autoUpdate = false
    @renderer.shadowMap.type = THREE.BasicShadowMap

    @renderer.autoClearColor = false
    @renderer.autoClearDepth = false

    @bounds = new AE.Rectangle()

    @colorPassRenderTarget = new THREE.WebGLRenderTarget 1, 1, type: THREE.FloatType
    @colorPassScreenQuad = new AS.ScreenQuad @colorPassRenderTarget.texture
    
    # Color pass needs to replace the pixels but leave the depth buffer intact.
    @colorPassScreenQuad.material.depthWrite = false
    @colorPassScreenQuad.material.depthTest = false

    @pixelRender = new @constructor.PixelRender @
    @sourceImage = new @constructor.SourceImage @
    @debugCluster = new @constructor.DebugCluster @

    @cameraManager = new @constructor.CameraManager @

    # Initialize radiance state rendering and add enable to render hidden clusters during radiance update.
    LOI.Engine.RadianceState.initialize()
    LOI.Engine.RadianceState.Probe.cubeCamera.layers.enable 3

    # Add a debug radiance cube sphere.
    sceneHelper = @meshCanvas.sceneHelper()
    scene = sceneHelper.scene()

    radianceDebugSphereMaterial = new THREE.MeshBasicMaterial
      color: 0xffffff
      envMap: LOI.Engine.RadianceState.Probe.cubeCamera.renderTarget.texture

    radianceDebugSphere = new THREE.Mesh new THREE.SphereBufferGeometry(0.5, 32, 32), radianceDebugSphereMaterial
    radianceDebugSphere.layers.set 4
    scene.add radianceDebugSphere

    radianceDebugProbeOctahedronMapMaterial = new THREE.MeshBasicMaterial
      color: 0xffffff
      map: LOI.Engine.RadianceState.Probe.octahedronMap
      side: THREE.DoubleSide

    radianceDebugProbeOctahedronMap = new THREE.Mesh new THREE.PlaneBufferGeometry(0.5, 1), radianceDebugProbeOctahedronMapMaterial
    radianceDebugProbeOctahedronMap.position.x = 1
    radianceDebugProbeOctahedronMap.rotation.x = Math.PI
    radianceDebugProbeOctahedronMap.layers.set 4
    scene.add radianceDebugProbeOctahedronMap

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
      @colorPassRenderTarget.setSize canvasPixelSize.width, canvasPixelSize.height

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
    @_radianceStatesToBeUpdated = []

    unless @constructor._lastMouseMoveTime
      @constructor._lastMouseMoveTime = Date.now()

      $(document).on "mousemove.landsofillusions-assets-mesheditor-meshcanvas-renderer", (event) =>
        @constructor._lastMouseMoveTime = Date.now()

  destroy: ->
    @renderer.dispose()

  draw: (appTime) ->
    radianceWasUpdated = false
    totalUpdatedCount = 0

    if @meshCanvas.pbrEnabled()
      # We're doing PBR so we should update some of the radiance
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

        # Set the PBR material on all meshes.
        scene = @meshCanvas.sceneHelper().scene()

        scene.traverse (object) =>
          return unless object.isMesh

          # Remember if the object is supposed to be visible since we'll change it depending if it's a PBR mesh or not.
          object.wasVisible = object.visible

          if object.pbrMaterial or object.material.pbr
            object.visible = true
            object.material = object.pbrMaterial if object.pbrMaterial

            # Enable double sided rendering during radiance transfer.
            object.pbrMaterial?.side = THREE.DoubleSide

            # TODO: Remove when CubeCamera supports layers.
            object.layers.enable 0 if object.layers.mask & 8

          else
            object.visible = false

        # Start rendering loop.
        @_setLinearRendering()
        @renderer.shadowMap.enabled = false

        while performance.now() < highPrecisionUpdateEndTime
          # Make sure we have a radiance state to update.
          unless @_radianceStatesToBeUpdated.length
            scene.traverse (object) =>
              return unless object instanceof LOI.Assets.Engine.Mesh.Object.Layer.Cluster
              engineCluster = object

              return unless engineCluster.data.isVisible()
              return unless radianceState = engineCluster.radianceState()

              # We should update one radiance state per 10×10 cluster pixels.
              updatesCount = Math.ceil radianceState.probeMap.pixelsCount / 100

              if updatesCount < 1
                updatesCount = if updatesCount > Math.random() then 1 else 0

              else
                updatesCount = Math.ceil updatesCount

              @_radianceStatesToBeUpdated.push radianceState for i in [0...updatesCount]

          # If we still don't have any radiance states to update, there aren't any clusters in the scene.
          break unless @_radianceStatesToBeUpdated.length

          # Update next radiance state.
          radianceState = @_radianceStatesToBeUpdated.shift()
          radianceState.update @renderer, scene
          radianceWasUpdated = true
          totalUpdatedCount++

        # Reinstate main materials and object visibility.
        scene.traverse (object) =>
          return unless object.isMesh

          object.visible = object.wasVisible
          object.material = object.mainMaterial if object.mainMaterial

          # Reinstate single-sided rendering for main render.
          object.pbrMaterial?.side = THREE.FrontSide

          # TODO: Remove when CubeCamera supports layers.
          object.layers.disable 0 if object.layers.mask & 8

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
    @renderer.toneMapping = THREE.LinearToneMapping

    exposureValue = @meshCanvas.interface.getHelperForActiveFile LOI.Assets.Editor.Helpers.ExposureValue
    @renderer.toneMappingExposure = exposureValue.exposure()

  _render: ->
    sceneHelper = @meshCanvas.sceneHelper()
    scene = sceneHelper.scene.withUpdates()

    camera = @cameraManager.camera.withUpdates()

    # Set up main geometry.
    camera.main.layers.set 0

    pbr = @meshCanvas.pbrEnabled()

    @_setLinearRendering()

    unless pbr
      shadowsEnabled = @meshCanvas.interface.getHelperForActiveFile LOI.Assets.MeshEditor.Helpers.ShadowsEnabled

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

      # Enable/disable updating of shadow map.
      @renderer.shadowMap.enabled = shadowsEnabled()
      @renderer.shadowMap.needsUpdate = true

    # Render main geometry pass that we use for depth and shadows.
    camera.main.layers.set 0
    @renderer.setClearColor 0, 0
    @renderer.setRenderTarget null
    @renderer.clear()
    @renderer.render scene, camera.main

    # Render main geometry color pass.
    @renderer.setRenderTarget @colorPassRenderTarget
    @renderer.clear()
    @renderer.render scene, camera.main

    # Present the color pass to screen (tone-mapped for PBR).
    @_setToneMappedRendering() if pbr
    @renderer.setRenderTarget null
    @renderer.render @colorPassScreenQuad.scene, @colorPassScreenQuad.camera

    if @meshCanvas.pixelRenderEnabled()
      # Render main geometry to the low-res render target.
      @_setLinearRendering()
      @renderer.setRenderTarget @pixelRender.renderTarget
      @renderer.setClearColor 0, 0
      @renderer.clear()
      @renderer.render scene, camera.renderTarget

      # Present the low-res render to the screen (tone-mapped for PBR).
      @_setToneMappedRendering() if pbr
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
    camera.main.layers.set 1
    @renderer.render scene, camera.main

    # Render debug visuals.
    if @meshCanvas.debugMode()
      camera.main.layers.set 2
      camera.main.layers.enable 3
      @renderer.render scene, camera.main

      # Render PBR debug visuals.
      if pbr
        @_setToneMappedRendering()
        debugClusterScene = @debugCluster.scene.withUpdates()
        @renderer.render debugClusterScene, camera.pixelRender

        @renderer.clearDepth()
        camera.main.layers.set 4
        @renderer.render scene, camera.main
