AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

class LOI.Engine.Skydome extends AS.RenderObject
  constructor: (@options = {}) ->
    super arguments...

    # Create the sphere mesh.
    @material = @createMaterial()
    @sphere = new THREE.Mesh new THREE.SphereBufferGeometry(950, 32, 16), @material

    @add @sphere

    if @options.generateCubeTexture
      # Prepare for rendering the cube texture.
      @cubeCamera = new THREE.CubeCamera 1, 100, @options.resolution,
        type: THREE.FloatType

      @cubeTexture = @cubeCamera.renderTarget.texture

      @cubeScene = new THREE.Scene()
      @cubeScene.add new THREE.Mesh new THREE.SphereBufferGeometry(10, 32, 16), new @constructor.Material
        map: @renderTarget.texture

  updateTexture: (renderer) ->
    # Optionally re-render the skydome to a cube texture.
    if @options.generateCubeTexture
      renderer.outputEncoding = THREE.LinearEncoding
      renderer.toneMapping = THREE.NoToneMapping
      @cubeCamera.update renderer, @cubeScene

  destroy: ->
    super arguments...

    @cubeCamera.dispose()
