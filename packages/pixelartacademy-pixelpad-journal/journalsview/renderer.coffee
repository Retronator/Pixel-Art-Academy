AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Journal.JournalsView.Renderer
  constructor: (@journalsView) ->
    @renderer = new THREE.WebGLRenderer

    @renderer.shadowMap.enabled = true
    @renderer.shadowMap.type = THREE.BasicShadowMap

    @renderer.setClearColor new THREE.Color 0x888888
    @renderer.autoClearColor = false

    @bounds = new AE.Rectangle()

    # Resize the canvas when app size changes.
    @journalsView.autorun =>
      # Depend on app's actual (animating) size.
      pixelPadSize = @journalsView.journal.os.pixelPad.animatingSize()

      # Resize the back buffer to canvas element size.
      @renderer.setSize pixelPadSize.width, pixelPadSize.height

      @bounds.width pixelPadSize.width
      @bounds.height pixelPadSize.height

  destroy: ->
    @renderer.dispose()

  start: ->
    # Start the reactive redraw routine.
    @journalsView.autorun =>
      # Depend on renderer bounds.
      @bounds.width() and @bounds.height()

      scene = @journalsView.sceneManager().scene.withUpdates()
      camera = @journalsView.camera.withUpdates()

      @renderer.render scene, camera

      @journalsView.sceneImage().update()
