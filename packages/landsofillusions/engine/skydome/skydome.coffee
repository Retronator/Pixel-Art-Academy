AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

class LOI.Engine.Skydome extends AS.RenderObject
  constructor: (options = {}) ->
    options.resolution ?= 1024

    super arguments...

    @options = options

    # Create the sphere mesh.
    @material = @createMaterial()
    @sphere = new THREE.Mesh new THREE.SphereBufferGeometry(950, 64, 64), @material

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
      cubeSceneSphere = new THREE.Mesh new THREE.SphereBufferGeometry(10, 64, 64), @cubeSceneSphereMaterial
      # We flip the sphere so the cube map directions will match the scene when applied as an environment map.
      cubeSceneSphere.scale.x = -1
      @cubeScene.add cubeSceneSphere

  updateTexture: (renderer) ->
    # Optionally re-render the skydome to a cube texture.
    if @options.generateCubeTexture
      renderer.outputEncoding = THREE.LinearEncoding
      renderer.toneMapping = THREE.NoToneMapping
      @cubeCamera.update renderer, @cubeScene
