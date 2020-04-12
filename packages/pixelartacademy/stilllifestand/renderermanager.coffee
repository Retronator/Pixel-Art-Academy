AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.RendererManager
  constructor: (@stillLifeStand) ->
    @renderer = new THREE.WebGLRenderer
      powerPreference: 'high-performance'

    @renderer.physicallyCorrectLights = true

    @mainRenderTarget = new THREE.WebGLRenderTarget 1, 1,
      minFilter: THREE.NearestFilter
      magFilter: THREE.NearestFilter

    # Create the screen quad with which to render the main image to the screen.
    @screenQuad = new AS.ScreenQuad @mainRenderTarget.texture

    # Resize the renderer and render targets when canvas size changes.
    @stillLifeStand.autorun =>
      viewport = LOI.adventure.interface.display.viewport()
      scale = LOI.adventure.interface.display.scale()

      width = viewport.viewportBounds.width()
      height = viewport.viewportBounds.height()

      return unless width and height

      @renderer.setSize width, height
      @mainRenderTarget.setSize width / scale, height / scale

  destroy: ->
    @renderer.dispose()
    @mainRenderTarget.dispose()

  draw: (appTime) ->
    scene = @stillLifeStand.sceneManager().scene
    camera = @stillLifeStand.cameraManager().camera

    # Render main pass.
    @renderer.outputEncoding = THREE.sRGBEncoding
    @renderer.toneMapping = THREE.LinearToneMapping
    @renderer.toneMappingExposure = 2 ** 3

    @renderer.setClearColor 0xff8800, 1
    @renderer.setRenderTarget @mainRenderTarget
    @renderer.render scene, camera

    # Render result to the screen.
    @renderer.outputEncoding = THREE.LinearEncoding
    @renderer.toneMapping = THREE.NoToneMapping

    @renderer.setClearColor 0x8888ff, 1
    @renderer.setRenderTarget null
    @renderer.render @screenQuad.scene, @screenQuad.camera
