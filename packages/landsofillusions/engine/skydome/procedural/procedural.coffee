AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid
LOI = LandsOfIllusions

_readColorsArray = new Float32Array 9 * 2 * 4

class LOI.Engine.Skydome.Procedural extends LOI.Engine.Skydome
  @worldToSkydomeMatrix: new THREE.Matrix4().makeRotationX(Math.PI / 2)

  constructor: (options = {}) ->
    options.scatteringResolution ?= 256
    options.renderStar ?= true

    super options

    # Create render target for rendering the scattering contribution to.
    renderTargetOptions =
      type: THREE.FloatType
      stencilBuffer: false
      depthBuffer: false

    @scatteringRenderTarget = new THREE.WebGLRenderTarget @options.scatteringResolution, @options.scatteringResolution, renderTargetOptions

    @scatteringRenderMaterial = new @constructor.RenderMaterial.Scattering @options

    # The scattering contribution is used for rendering indirect light.
    @indirectMaterial = @createMaterial()
    @indirectMaterial.map = @scatteringRenderTarget.texture
    @indirectMaterial.uniforms.map.value = @scatteringRenderTarget.texture

    @indirectSphere = new THREE.Mesh @geometry, @indirectMaterial
    @indirectSphere.scale.multiplyScalar options.distance
    @indirectSphere.layers.set LOI.Engine.RenderLayers.Indirect

    @add @indirectSphere

    # Create render target for the final render with direct and scattered light.
    @renderTarget = new THREE.WebGLRenderTarget @options.resolution, @options.resolution, renderTargetOptions
    @renderMaterial = new @constructor.RenderMaterial _.extend
      scatteringMap: @scatteringRenderTarget.texture
    ,
      @options

    # Create the scenes for rendering the sky textures.
    @scatteringScene = new THREE.Scene()
    @scatteringScene.add new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), @scatteringRenderMaterial

    @scene = new THREE.Scene()
    @scene.add new THREE.Mesh new THREE.PlaneBufferGeometry(2, 2), @renderMaterial

    # Create a dummy camera since it's not used in the render material shader.
    @camera = new THREE.Camera

    # Set material on the sphere.
    @material.map = @renderTarget.texture
    @material.uniforms.map.value = @renderTarget.texture

    if @options.generateCubeTexture or @options.generateEnvironmentMap
      # Cube texture should only have indirect light since it is used
      # to render an environment map, which should have indirect light only.
      @cubeSceneSphereMaterial.map = @scatteringRenderTarget.texture
      @cubeSceneSphereMaterial.uniforms.map.value = @scatteringRenderTarget.texture

    if @options.readColors or @options.addDirectionalLight
      # Prepare for reading generated sky colors.
      @readColorsRenderTarget = new THREE.WebGLRenderTarget 6, 3,
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

      @skyColor = new THREE.Color
      @starColor = new THREE.Color

    if @options.addDirectionalLight
      @directionalLight = new THREE.DirectionalLight
      @directionalLight.layers.mask = LOI.Engine.RenderLayerMasks.GeometricLight

      @add @directionalLight

  createMaterial: ->
    new @constructor.Material
      resolution: @options.resolution
      dithering: @options.dithering

  updateTexture: (renderer, starDirection, starFactor, scatteringFactor) ->
    # Update star light direction.
    starDirectionOctahedron = new THREE.Vector3().copy(starDirection).normalize().applyMatrix4(@constructor.worldToSkydomeMatrix)

    @scatteringRenderMaterial.uniforms.scatteringFactor.value = scatteringFactor ? @renderMaterial.options.intensityFactors.scattering
    @scatteringRenderMaterial.uniforms.starDirection.value.copy starDirectionOctahedron
    @renderMaterial.uniforms.starDirection.value.copy starDirectionOctahedron
    @renderMaterial.uniforms.starFactor.value = starFactor ? @renderMaterial.options.intensityFactors.star

    # Render the low-resolution scattering contribution.
    if @renderMaterial.uniforms.scatteringFactor.value > 0
      renderer.setRenderTarget @scatteringRenderTarget
      renderer.render @scatteringScene, @camera

    # Render the high-resolution full sky.
    renderer.setRenderTarget @renderTarget
    renderer.render @scene, @camera

    # Do any additional rendering.
    super arguments...

    if @options.readColors or @options.addDirectionalLight
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

      renderer.readRenderTargetPixels @readColorsRenderTarget, 0, 0, 6, 3, _readColorsArray

      # Take the average of the 8 darkest pixels in the (0, 0)–(2, 2) range for sky color.
      # We do this to avoid the pixel that has a strong contribution of mie scattering.
      @skyColor.set 0
      brightestSample = null

      for x in [0..2]
        for y in [0..2]
          pixelOffset = (x + y * 6) * 4
          skySample =
            r: _readColorsArray[pixelOffset]
            g: _readColorsArray[pixelOffset + 1]
            b: _readColorsArray[pixelOffset + 2]

          @skyColor.add skySample

          if skySample.g > (brightestSample?.g or 0)
            brightestSample = skySample

      @skyColor.sub brightestSample if brightestSample
      @skyColor.multiplyScalar 1 / (if brightestSample then 8 else 9)
      skyXYZ = AS.Color.SRGB.getXYZForRGB @skyColor
      @skyColor.normalize()

      @skyLuminance = AS.Color.XYZ.getLuminanceForY(skyXYZ.y)

      if starIsUnderHorizon
        @starColor.set 0
        @starLuminance = 0

      else
        # Read pixel (4, 1) for sun's color.
        @starColor.setRGB _readColorsArray[40], _readColorsArray[41], _readColorsArray[42]
        starXYZ = AS.Color.SRGB.getXYZForRGB @starColor
        @starColor.normalize()

        @starLuminance = AS.Color.XYZ.getLuminanceForY(starXYZ.y)

    if @options.addDirectionalLight
      @directionalLight.position.copy(starDirection).normalize().multiplyScalar -(@options.directionalLightDistance or @options.distance)
      @directionalLight.color.copy @starColor
      # TODO: 2e-8 factor was determined experimentally to match real HDR probes. The math behind this needs to be rechecked.
      @directionalLight.intensity = @starLuminance * 2e-8
