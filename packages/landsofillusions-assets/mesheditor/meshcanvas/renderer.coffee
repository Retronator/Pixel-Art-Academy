AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer
  constructor: (@meshCanvas) ->
    @renderer = new THREE.WebGLRenderer
      canvas: @meshCanvas.canvas()
      context: @meshCanvas.context()

    @renderer.shadowMap.enabled = true
    @renderer.shadowMap.autoUpdate = false
    @renderer.shadowMap.type = THREE.BasicShadowMap

    @renderer.setClearColor new THREE.Color 0x565656
    @renderer.autoClearColor = false
    @renderer.autoClearDepth = false

    @bounds = new AE.Rectangle()

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

      sceneManager = @meshCanvas.sceneManager()
      scene = sceneManager.scene.withUpdates()
      pictureScene = sceneManager.pictureScene.withUpdates()
      renderTarget = sceneManager.pictureRenderTarget

      camera = @meshCanvas.cameraManager().camera.withUpdates()

      # Render main geometry pass that we use for depth and shadows (and color when not showing the render target).
      camera.main.layers.set 0
      @renderer.clear()
      @renderer.shadowMap.needsUpdate = true
      @renderer.render scene, camera.main
      
      if @meshCanvas.options.drawPixelImage()
        # Render main geometry to the render target.
        @renderer.setRenderTarget renderTarget
        @renderer.clear()
        @renderer.render scene, camera.renderTarget, renderTarget

        # Render the low-res picture to the main scene.
        @renderer.render pictureScene, camera.picture

      # Render helpers that overlay the geometry.
      camera.main.layers.set 1
      @renderer.render scene, camera.main

      # Render debug visuals.
      if @meshCanvas.options.debug()
        camera.main.layers.set 2
        @renderer.render scene, camera.main

  destroy: ->
    @renderer.dispose()
