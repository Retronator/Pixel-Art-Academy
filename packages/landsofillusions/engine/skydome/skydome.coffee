AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

_readColorsArray = new Float32Array 8

class LOI.Engine.Skydome extends AS.RenderObject
  @worldToSkydomeMatrix: new THREE.Matrix4().makeRotationX(Math.PI / 2)

  constructor: (@options = {}) ->
    super arguments...

    @options.scatteringResolution ?= 128
    @options.resolution ?= 1024

    # Create render target for rendering the scattering contribution to.
    renderTargetOptions =
      type: THREE.FloatType
      stencilBuffer: false
      depthBuffer: false

    @scatteringRenderTarget = new THREE.WebGLRenderTarget @options.scatteringResolution, @options.scatteringResolution, renderTargetOptions

    @scatteringRenderMaterial = new @constructor.RenderMaterial.Scattering

    # Create render target for the final render target with direct and scattered light.
    @renderTarget = new THREE.WebGLRenderTarget @options.resolution, @options.resolution, renderTargetOptions
    @renderMaterial = new @constructor.RenderMaterial
      scatteringMap: @scatteringRenderTarget.texture

    # Create the scenes and camera for rendering.
    @scatteringScene = new THREE.Scene()
    @scatteringScene.add new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), @scatteringRenderMaterial

    @scene = new THREE.Scene()
    @scene.add new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), @renderMaterial

    @camera = new THREE.OrthographicCamera 0, 1, 0, 1, 0.5, 1.5

    # Create the sphere mesh.
    sphere = new THREE.Mesh new THREE.SphereBufferGeometry(950, 32, 16), new @constructor.Material
      map: @renderTarget.texture
      resolution: @options.resolution
      dithering: @options.dithering

    @add sphere

    if @options.generateCubeTexture
      # Prepare for rendering the cube texture.
      @cubeCamera = new THREE.CubeCamera 1, 100, @options.resolution,
        type: THREE.FloatType

      @cubeTexture = @cubeCamera.renderTarget.texture

      @cubeScene = new THREE.Scene()
      @cubeScene.add new THREE.Mesh new THREE.SphereBufferGeometry(10, 32, 16), new @constructor.Material
        map: @renderTarget.texture

    if @options.readColors
      # Prepare for reading generated sky colors.
      @readColorsRenderTarget = new THREE.WebGLRenderTarget 2, 1,
        type: THREE.FloatType
        magFilter: THREE.NearestFilter
        minfilter: THREE.NearestFilter

      @readColorsScene = new THREE.Scene()

      skyColorQuad = new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), new THREE.MeshBasicMaterial
        map: @scatteringRenderTarget.texture

      skyColorQuad.position.x = -1
      @readColorsScene.add skyColorQuad

      @starColorQuad = new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), new THREE.MeshBasicMaterial
        map: @renderTarget.texture

      @starColorQuad.position.x = 1
      @readColorsScene.add @starColorQuad

      @readColorsCamera = new THREE.OrthographicCamera -2, 2, 1, -1, 0.5, 1.5
      @readColorsCamera.position.z = 1

      @skySpectrum = new AR.Optics.Spectrum.RGB
      @starSpectrum = new AR.Optics.Spectrum.RGB

      @skyColor = new THREE.Color
      @starColor = new THREE.Color

  updateTexture: (renderer, starDirection) ->
    # Update star light direction.
    starDirectionOctahedron = new THREE.Vector3().copy(starDirection).normalize().applyMatrix4(@constructor.worldToSkydomeMatrix)

    @scatteringRenderMaterial.uniforms.starDirection.value.copy starDirectionOctahedron
    @renderMaterial.uniforms.starDirection.value.copy starDirectionOctahedron

    # Render the low-resolution scattering contribution.
    renderer.setRenderTarget @scatteringRenderTarget
    renderer.render @scatteringScene, @camera

    # Render the high-resolution full sky.
    renderer.setRenderTarget @renderTarget
    renderer.render @scene, @camera

    # Optionally re-render the skydome to a cube texture.
    if @options.generateCubeTexture
      renderer.outputEncoding = THREE.LinearEncoding
      renderer.toneMapping = THREE.NoToneMapping
      @cubeCamera.update renderer, @cubeScene

    if @options.readColors
      # Update star sample position.
      starSampleCenter = AP.OctahedronMap.directionToPosition starDirectionOctahedron.clone().negate(), @options.resolution

      if starSampleCenter.y > 0.5
        # Sun is under the horizon so it should be black.
        starIsUnderHorizon = true

      else
        starSampleCenter.y *= 2
        starSampleRadius = 0.5 / @options.resolution

        uvsArray = @starColorQuad.geometry.attributes.uv.array
        uvsArray[0] = starSampleCenter.x - starSampleRadius
        uvsArray[1] = starSampleCenter.y + starSampleRadius
        uvsArray[2] = starSampleCenter.x + starSampleRadius
        uvsArray[3] = starSampleCenter.y + starSampleRadius
        uvsArray[4] = starSampleCenter.x - starSampleRadius
        uvsArray[5] = starSampleCenter.y - starSampleRadius
        uvsArray[6] = starSampleCenter.x + starSampleRadius
        uvsArray[7] = starSampleCenter.y - starSampleRadius

        @starColorQuad.geometry.attributes.uv.needsUpdate = true

      # Read generated colors.
      renderer.outputEncoding = THREE.LinearEncoding
      renderer.toneMapping = THREE.NoToneMapping

      renderer.setRenderTarget @readColorsRenderTarget
      renderer.render @readColorsScene, @readColorsCamera

      renderer.readRenderTargetPixels @readColorsRenderTarget, 0, 0, 2, 1, _readColorsArray

      @skySpectrum.array[i] = _readColorsArray[i] for i in [0..2]
      @skyColor.setRGB(_readColorsArray[0], _readColorsArray[1], _readColorsArray[2]).normalize()

      skyIlluminance = AS.Color.CIE1931.getLuminanceForSpectrum(@skySpectrum) * 0.015
      @skyIntensity = skyIlluminance

      if starIsUnderHorizon
        @starColor.set 0
        @starSpectrum.clear()

      else
        @starColor.setRGB(_readColorsArray[4], _readColorsArray[5], _readColorsArray[6]).normalize()
        @starSpectrum.array[i] = _readColorsArray[4 + i] for i in [0..2]

      starIlluminance = AS.Color.CIE1931.getLuminanceForSpectrum(@starSpectrum) * 6.807e-5 * 8
      @starIntensity = starIlluminance

  destroy: ->
    super arguments...

    @renderTarget.dispose()
