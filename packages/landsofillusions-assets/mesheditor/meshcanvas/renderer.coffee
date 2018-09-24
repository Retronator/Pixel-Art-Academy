AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.MeshCanvas.Renderer
  constructor: (@meshRenderer) ->
    @renderer = new THREE.WebGLRenderer
      canvas: @meshRenderer.canvas()
      context: @meshRenderer.context()

    @renderer.setClearColor new THREE.Color 0x565656
    @renderer.autoClearColor = false

    @bounds = new AE.Rectangle()

    # Resize the renderer when canvas size changes.
    @meshRenderer.autorun =>
      return unless canvasPixelSize = @meshRenderer.canvasPixelSize()
      @renderer.setSize canvasPixelSize.width, canvasPixelSize.height

      @bounds.width canvasPixelSize.width
      @bounds.height canvasPixelSize.height

    # Start the reactive redraw routine.
    @meshRenderer.autorun =>
      # Depend on renderer bounds.
      @bounds.width() and @bounds.height()

      scene = @meshRenderer.sceneManager().scene.withUpdates()
      camera = @meshRenderer.cameraManager().camera.withUpdates()

      @renderer.render scene, camera

  destroy: ->
    @renderer.dispose()
