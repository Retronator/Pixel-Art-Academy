AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.RendererManager
  constructor: (@stillLifeStand) ->
    @renderer = new THREE.WebGLRenderer
      powerPreference: 'high-performance'

    @renderer.autoClear = false
    @renderer.physicallyCorrectLights = true
    @renderer.shadowMap.enabled = true
    @renderer.shadowMap.autoUpdate = false
    @renderer.shadowMap.type = THREE.PCFSoftShadowMap

    @mainRenderTarget = new THREE.WebGLRenderTarget 1, 1,
      type: THREE.FloatType
      minFilter: THREE.NearestFilter
      magFilter: THREE.NearestFilter

    # Create the screen quad with which to render the main image to the screen.
    @screenQuad = new AS.ScreenQuad @mainRenderTarget.texture
    @screenQuad.material.dithering = true

    # Resize the renderer and render targets when canvas size changes.
    @stillLifeStand.autorun =>
      viewport = LOI.adventure.interface.display.viewport()
      scale = LOI.adventure.interface.display.scale()

      renderTargetWidth = Math.ceil viewport.viewportBounds.width() / scale
      renderTargetHeight = Math.ceil viewport.viewportBounds.height() / scale

      return unless renderTargetWidth and renderTargetHeight

      @renderer.setSize renderTargetWidth * scale, renderTargetHeight * scale
      @mainRenderTarget.setSize renderTargetWidth, renderTargetHeight

    @renderDebug = false

    @exposureValue = new ReactiveField -1

    @environmentMapGenerator = new THREE.PMREMGenerator @renderer

  destroy: ->
    @renderer.dispose()
    @mainRenderTarget.dispose()

  draw: (appTime) ->
    scene = @stillLifeStand.sceneManager().scene
    camera = @stillLifeStand.cameraManager().camera()

    # Render main pass.
    @renderer.outputEncoding = THREE.LinearEncoding
    @renderer.toneMapping = THREE.NoToneMapping

    @renderer.setRenderTarget @mainRenderTarget
    @renderer.clear()
    @renderer.shadowMap.needsUpdate = true
    @renderer.render scene, camera

    if @renderDebug
      # Render debug pass.
      debugScene = @stillLifeStand.sceneManager().debugScene
      @renderer.render debugScene, camera

    # Render result to the screen.
    @renderer.outputEncoding = THREE.sRGBEncoding
    @renderer.toneMapping = THREE.ACESFilmicToneMapping
    @renderer.toneMappingExposure = 2 ** @exposureValue()

    @renderer.setRenderTarget null
    @renderer.render @screenQuad.scene, @screenQuad.camera
