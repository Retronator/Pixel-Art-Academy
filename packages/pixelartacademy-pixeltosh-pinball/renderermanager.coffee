AE = Artificial.Everywhere
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.RendererManager
  @width = 180 # px
  @height = 200 # px
  @aspectRatio = @width / @height

  constructor: (@pinball) ->
    @renderer = new THREE.WebGLRenderer
      powerPreference: 'high-performance'

    @renderer.shadowMap.enabled = true
    @renderer.setSize @constructor.width, @constructor.height
    @renderer.setClearColor new THREE.Color 0x00ffff

  destroy: ->
    @renderer.dispose()

  draw: (appTime) ->
    scene = @pinball.sceneManager().scene
    camera = @pinball.cameraManager().camera()

    @renderer.render scene, camera
