AS = Artificial.Spectrum
AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.Engine.Skydome extends AS.RenderObject
  @resolution: 512
  @worldToSkydomeMatrix: new THREE.Matrix4().makeRotationX(Math.PI / 2)

  constructor: (@options) ->
    super arguments...

    # Create render target for rendering the sky to.
    @renderTarget = new THREE.WebGLRenderTarget @constructor.resolution, @constructor.resolution,
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

    sphere.layers.set 3

    @add sphere

  updateTexture: (renderer, starDirection) ->
    @renderMaterial.uniforms.starDirection.value.copy(starDirection).applyMatrix4(@constructor.worldToSkydomeMatrix)

    renderer.setRenderTarget @renderTarget
    renderer.render @scene, @camera

  destroy: ->
    super arguments...

    @renderTarget.dispose()
