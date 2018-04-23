AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalsView.Renderer
  constructor: (@journalsView) ->
    @renderer = new THREE.WebGLRenderer

    @renderer.shadowMap.enabled = true
    @renderer.shadowMap.type = THREE.PCFShadowMap

    @renderer.setClearColor new THREE.Color 0x888888
    @renderer.autoClearColor = false

    @bounds = new AE.Rectangle()

    # Resize the canvas when app size changes.
    @journalsView.autorun =>
      # Depend on app's actual (animating) size.
      pixelBoySize = @journalsView.journal.os.pixelBoy.animatingSize()

      # Resize the back buffer to canvas element size.
      @renderer.setSize pixelBoySize.width, pixelBoySize.height

      @bounds.width pixelBoySize.width
      @bounds.height pixelBoySize.height

  destroy: ->
    @renderer.dispose()

  start: ->
    # Append the WebGL canvas.
    $scene = @journalsView.$('.scene')
    $scene.append @renderer.domElement

    # Start the reactive redraw routine.
    @journalsView.autorun =>
      # Depend on renderer bounds.
      @bounds.width() and @bounds.height()

      scene = @journalsView.sceneManager().scene.withUpdates()
      camera = @journalsView.camera.withUpdates()

      @renderer.render scene, camera
