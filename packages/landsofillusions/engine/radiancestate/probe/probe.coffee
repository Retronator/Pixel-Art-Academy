LOI = LandsOfIllusions

class LOI.Engine.RadianceState.Probe
  @cubeResolution: 256
  @octahedronMapMaxLevel: 9
  @octahedronMapResolution: 2 ** @octahedronMapMaxLevel

  @initialize: ->
    @cubeCameraRenderTarget = new THREE.WebGLCubeRenderTarget @cubeResolution,
      # Note: Support for RGB Float textures is not as wide as RGBA so
      # we don't use RGB, even though we don't need the alpha channel.
      format: THREE.RGBAFormat
      type: THREE.FloatType
      stencilBuffer: false

    # Prepare rendering of the radiance cube.
    @cubeCamera = new THREE.CubeCamera 0.001, 1000, @cubeCameraRenderTarget
    @cubeCamera.layers.set LOI.Engine.RenderLayers.Indirect

    # Create render target for extracting the probe cube to an octahedron map.
    @octahedronMapRenderTarget = new THREE.WebGLRenderTarget @octahedronMapResolution, @octahedronMapResolution * 2,
      type: THREE.FloatType
      stencilBuffer: false
      depthBuffer: false
      generateMipmaps: true
      minFilter: THREE.LinearMipmapNearestFilter

    @octahedronMap = @octahedronMapRenderTarget.texture

    @octahedronMapMaterial = new @OctahedronMapMaterial
    octahedronMapQuad = new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), @octahedronMapMaterial

    @octahedronMapScene = new THREE.Scene()
    @octahedronMapScene.add octahedronMapQuad

    @octahedronMapCamera = new THREE.OrthographicCamera 0, 1, 0, 1, 0.5, 1.5

  @update: (renderer) ->
    # Update octahedron map (it is assumed cube camera was used to render new data prior to this).
    renderer.setRenderTarget @octahedronMapRenderTarget
    renderer.render @octahedronMapScene, @octahedronMapCamera
