AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

class LOI.Engine.Skydome extends AS.RenderObject
  constructor: (@options = {}) ->
    super arguments...

    # Create the sphere mesh.
    @material = @createMaterial()
    @sphere = new THREE.Mesh new THREE.SphereBufferGeometry(950, 64, 64), @material

    @add @sphere

    if @options.generateCubeTexture
      # Prepare for rendering the cube texture.
      @cubeCamera = new THREE.CubeCamera 1, 100, @options.resolution,
        type: THREE.FloatType

      @cubeTexture = @cubeCamera.renderTarget.texture

      @cubeScene = new THREE.Scene()
      @cubeSceneSphereMaterial = @createMaterial()
      @cubeScene.add new THREE.Mesh new THREE.SphereBufferGeometry(10, 64, 64), @cubeSceneSphereMaterial

  updateTexture: (renderer) ->
    # Optionally re-render the skydome to a cube texture.
    if @options.generateCubeTexture
      renderer.outputEncoding = THREE.LinearEncoding
      renderer.toneMapping = THREE.NoToneMapping
      @cubeCamera.update renderer, @cubeScene

  destroy: ->
    super arguments...

    @cubeCamera.dispose()
