AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.Engine.Skydome extends AS.RenderObject
  @worldToSkydomeMatrix: new THREE.Matrix4().makeRotationX(Math.PI / 2)

  constructor: (@options = {}) ->
    super arguments...

    @options.resolution ?= 512

    # Create render target for rendering the sky to.
    @renderTarget = new THREE.WebGLRenderTarget @options.resolution, @options.resolution,
      type: THREE.FloatType
      stencilBuffer: false
      depthBuffer: false

    @renderMaterial = new @constructor.RenderMaterial
    quad = new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), @renderMaterial

    @scene = new THREE.Scene()
    @scene.add quad

    @camera = new THREE.OrthographicCamera 0, 1, 0, 1, 0.5, 1.5

    # Create the sphere mesh.
    sphere = new THREE.Mesh new THREE.SphereBufferGeometry(950, 32, 16), new @constructor.Material
      map: @renderTarget.texture
      resolution: @options.resolution

    @add sphere

    if @options.generateCubeTexture
      @cubeCamera = new THREE.CubeCamera 1, 100, @options.resolution,
        type: THREE.FloatType

      @cubeTexture = @cubeCamera.renderTarget.texture

      @cubeScene = new THREE.Scene()
      @cubeScene.add new THREE.Mesh new THREE.SphereBufferGeometry(10, 32, 16), new @constructor.Material
        map: @renderTarget.texture

  updateTexture: (renderer, starDirection) ->
    @renderMaterial.uniforms.starDirection.value.copy(starDirection).normalize().applyMatrix4(@constructor.worldToSkydomeMatrix)

    renderer.setRenderTarget @renderTarget
    renderer.render @scene, @camera

    @cubeCamera.update renderer, @cubeScene if @options.generateCubeTexture

  destroy: ->
    super arguments...

    @renderTarget.dispose()
