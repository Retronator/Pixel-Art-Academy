AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer
  constructor: (@meshCanvas) ->
    @renderer = new THREE.WebGLRenderer
      canvas: @meshCanvas.canvas()
      context: @meshCanvas.context()

    @renderer.shadowMap.autoUpdate = false
    @renderer.shadowMap.type = THREE.BasicShadowMap

    @renderer.setClearColor new THREE.Color 0x565656
    @renderer.autoClearColor = false
    @renderer.autoClearDepth = false

    @bounds = new AE.Rectangle()
    
    @pixelRender = new @constructor.PixelRender @
    @sourceImage = new @constructor.SourceImage @

    @cameraManager = new @constructor.CameraManager @

    # Resize the renderer when canvas size changes.
    @meshCanvas.autorun =>
      return unless canvasPixelSize = @meshCanvas.canvasPixelSize()

      @renderer.setSize canvasPixelSize.width, canvasPixelSize.height

      @bounds.width canvasPixelSize.width
      @bounds.height canvasPixelSize.height

    # Start the reactive redraw routine.
    @meshCanvas.autorun =>
      # Depend on renderer bounds.
      @bounds.width() and @bounds.height()
      
      sceneHelper = @meshCanvas.sceneHelper()
      scene = sceneHelper.scene.withUpdates()

      camera = @cameraManager.camera.withUpdates()

      # Render main geometry pass that we use for depth and shadows (and color when not showing the render target).
      camera.main.layers.set 0
      @renderer.clear()
      
      shadowsEnabled = @meshCanvas.interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.ShadowsEnabled, @meshCanvas.meshId()
      @renderer.shadowMap.enabled = shadowsEnabled()
      @renderer.shadowMap.needsUpdate = true
      @renderer.render scene, camera.main
      
      if @meshCanvas.pixelRenderEnabled()
        # Render main geometry to the render target.
        @renderer.setRenderTarget @pixelRender.renderTarget
        @renderer.clear()
        @renderer.render scene, camera.renderTarget, @pixelRender.renderTarget

        # Render the low-res picture to the main scene.
        pixelRenderScene = @pixelRender.scene.withUpdates()
        @renderer.render pixelRenderScene, camera.pixelRender

      if @meshCanvas.sourceImageEnabled()
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
