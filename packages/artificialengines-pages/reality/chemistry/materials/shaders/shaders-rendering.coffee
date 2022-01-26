AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Materials.Shaders extends AR.Pages.Chemistry.Materials.Shaders
  onCreated: ->
    super arguments...

    # Prepare renderer.
    @renderer = new THREE.WebGLRenderer
      powerPreference: 'high-performance'
      physicallyCorrectLights: true
      antialias: true

    @width = 1024
    @height = 512
    @renderer.setSize @width, @height

    # Prepare camera.
    @camera = new THREE.PerspectiveCamera 60, @width / @height, 0.1, 1000
    @camera.position.set 2.5, 0.5, -1.5

    @controls = new THREE.OrbitControls @camera, @renderer.domElement
    @controls.target.set -0.1, 0, 0

    # Prepare tone-mapped rendering.
    @toneMappingRenderTarget = new THREE.WebGLMultisampleRenderTarget @width, @height, type: THREE.FloatType
    @toneMappingScreenQuad = new AS.ScreenQuad @toneMappingRenderTarget.texture

    @autorun (computation) =>
      exposureValue = @exposureValue()
      @renderer.toneMappingExposure = 2 ** exposureValue

  update: (appTime) ->
    @controls.update()

  draw: (appTime) ->
    # Render raw colors.
    @renderer.outputEncoding = THREE.LinearEncoding
    @renderer.toneMapping = THREE.NoToneMapping

    @renderer.setRenderTarget @toneMappingRenderTarget
    @renderer.render @scene, @camera

    # Present tone-mapped result.
    @renderer.outputEncoding = THREE.sRGBEncoding
    @renderer.toneMapping = @constructor.ToneMappings[@toneMappingName()]

    @renderer.setRenderTarget null
    @renderer.render @toneMappingScreenQuad.scene, @toneMappingScreenQuad.camera
