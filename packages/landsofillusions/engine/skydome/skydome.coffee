AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

class LOI.Engine.Skydome extends AS.RenderObject
  constructor: (options = {}) ->
    options.resolution ?= 1024
    options.distance ?= 950

    super arguments...

    @options = options

    # Create the sphere mesh.
    @geometry = new THREE.SphereBufferGeometry 1, 64, 64
    @material = @createMaterial()
    @sphere = new THREE.Mesh @geometry, @material
    @sphere.scale.multiply options.distance

    @add @sphere

    if @options.generateCubeTexture
      # Prepare for rendering the cube texture.
      @cubeCameraRenderTarget = new THREE.WebGLCubeRenderTarget @options.resolution,
        format: THREE.RGBAFormat
        type: THREE.FloatType

      @cubeCamera = new THREE.CubeCamera 1, 100, @cubeCameraRenderTarget

      @cubeTexture = @cubeCameraRenderTarget.texture

      @cubeScene = new THREE.Scene()
      @cubeSceneSphereMaterial = @createMaterial()
      cubeSceneSphere = new THREE.Mesh @geometry, @cubeSceneSphereMaterial
      # We flip the sphere so the cube map directions will match the scene when applied as an environment map.
      cubeSceneSphere.scale.set -10, 10, 10
      @cubeScene.add cubeSceneSphere

  updateTexture: (renderer) ->
    # Optionally re-render the skydome to a cube texture.
    if @options.generateCubeTexture
      renderer.outputEncoding = THREE.LinearEncoding
      renderer.toneMapping = THREE.NoToneMapping
      @cubeCamera.update renderer, @cubeScene
