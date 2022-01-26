AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Materials.Shaders extends AR.Pages.Chemistry.Materials.Shaders
  @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders'

  onCreated: ->
    super arguments...

    # Create the scene.
    @scene = new THREE.Scene

    # Setup directional light.
    @directionalLight = new THREE.DirectionalLight
    @sunColorMeasureSkydome = new LOI.Engine.Skydome.Procedural readColors: true

    # Reactively adjust directional light to match the environment.
    @autorun (computation) =>
      sunPosition = @sunPosition()
      @directionalLight.position.copy sunPosition

      sunDirection = sunPosition.clone().negate()
      @sunColorMeasureSkydome.updateTexture @renderer, sunDirection, @sunFactor(), 0

      @directionalLight.color.copy @sunColorMeasureSkydome.starColor
      @directionalLight.intensity = @sunColorMeasureSkydome.starLuminance * 2e-8

    # Directional light needs to be activated in the main procedural
    # environment and photo environments that have the sun directly visible.
    @autorun (computation) =>
      environmentName = @environmentName()

      if environmentName is 'Procedural' or @constructor.ProceduralSkySettings[environmentName]
        @scene.add @directionalLight

      else
        @scene.remove @directionalLight

    # Prepare for generating the environment map.
    @environmentMapGenerator = new THREE.PMREMGenerator @renderer

    # Generate the environment map from the sky texture.
    @skyTexture = new ReactiveField null

    @_environmentMapRenderTarget = null
    @environmentMap = new ComputedField =>
      return unless skyTexture = @skyTexture()

      @_environmentMapRenderTarget?.dispose()
      @_environmentMapRenderTarget = @environmentMapGenerator.fromCubemap skyTexture
      @_environmentMapRenderTarget.texture

    # Create the skydome and render the sky texture.
    @autorun (computation) =>
      environmentUrl = @environmentUrl()
      @scene.remove @skydome if @skydome

      if @environmentIsProcedural()
        # In the indirect-only procedural sky we want to render a bigger sun to make the lighting
        # more stable since the environment map generated with PMREMGenerator is quite low resolution.
        indirectOnly = environmentUrl is 'ProceduralIndirect'
        sunScale = if indirectOnly then 5 else 1
        sunAreaFactor = sunScale ** 2

        # We don't want to render the sun in the main procedural sky as the light will come from the direct light.
        starFactor = if indirectOnly then @sunFactor() / sunAreaFactor else 0
        scatteringFactor = @skyFactor()

        # Create the procedural skydome in case the previous one was a photo.
        unless @skydome instanceof LOI.Engine.Skydome.Procedural
          @skydome = new LOI.Engine.Skydome.Procedural
            resolution: 4096
            star:
              angularSize: 0.00931 * sunScale
            generateCubeTexture: true

        # Render the procedural sky.
        direction = @sunPosition().clone().multiplyScalar -1
        @skydome.updateTexture @renderer, direction, starFactor, scatteringFactor

        # Set the sky texture to trigger generation of the environment map.
        @skyTexture @skydome.cubeTexture

      else
        # Load the photo environment.
        @skydome = new LOI.Engine.Skydome.Photo
          generateCubeTexture: true
          onLoaded: =>
            # Render cube texture.
            @skydome.updateTexture @renderer
            @renderer.setRenderTarget null

            # Set the sky texture to trigger generation of the environment map.
            @skyTexture @skydome.cubeTexture

        @skydome.loadFromUrl environmentUrl

      # Add the new skydome to the scene.
      @scene.add @skydome

    # For scenes that have a directly visible sun we want to block it during environment map generation
    # so we only get indirect lighting contribution (the direct one will come from the direct light).
    sunBlockerGeometry = new THREE.SphereGeometry 25
    @sunBlockerMaterial = new THREE.MeshBasicMaterial color: 0
    @sunBlocker = new THREE.Mesh sunBlockerGeometry, @sunBlockerMaterial
    @sunBlocker.visible = false
    @scene.add @sunBlocker

    @autorun (computation) =>
      @sunBlocker.position.copy(@sunPosition()).multiplyScalar 950

    # Create the 5 preview spheres.
    sphereRadius = 0.25
    sphereGeometry = new THREE.SphereGeometry sphereRadius, 64, 32
    material = new THREE.MeshBasicMaterial color: 0xffffff

    @spheres = for i in [-2..2]
      sphere = new THREE.Mesh sphereGeometry, material
      sphere.position.z = i
      @scene.add sphere
      sphere

    # Reactively set chosen material and shader on the spheres.
    @autorun (computation) =>
      shaderClass = @shaderClass()
      environmentMap = @environmentMap()
      materialClass = @materialClass()

      # Determine reflectance at normal incidence (specular color).
      refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
      extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

      reflectanceSpectrum = new AR.Optics.Spectrum.Formulated (wavelength) =>
        refractiveIndex = refractiveIndexSpectrum.getValue wavelength
        extinctionCoefficient = extinctionCoefficientSpectrum?.getValue wavelength
        AR.Optics.FresnelEquations.getReflectance 0, 1, refractiveIndex, 0, extinctionCoefficient

      reflectanceRGB = new AR.Optics.Spectrum.RGB().copyFactor reflectanceSpectrum

      # Determine how conductive this material is.
      if extinctionCoefficientSpectrum
        extinctionCoefficientRGB = new AR.Optics.Spectrum.RGB().copyFactor extinctionCoefficientSpectrum
        conductivity = _.clamp extinctionCoefficientRGB.r(), 0, 1

      else
        conductivity = 0

      # Conductor color is simply the light it reflects.
      conductorColor = reflectanceRGB.toObject()

      # Dielectrics reflect color that entered the material.
      dielectricColor =
        r: 1 - conductorColor.r
        g: 1 - conductorColor.g
        b: 1 - conductorColor.b

      # Choose color between the two modes (dielectric/conductor).
      color = new THREE.Color().lerpColors dielectricColor, conductorColor, conductivity

      # Determine the average refractive index.
      refractiveIndexValues = new AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5().copy refractiveIndexSpectrum
      refractiveIndex = _.sum(refractiveIndexValues.array) / refractiveIndexValues.array.length

      # Determine how heterogeneous the subsurface structure is.
      subsurfaceHeterogeneity = @subsurfaceHeterogeneity()

      # Create materials on the spheres.
      for sphere, index in @spheres
        # The spheres differ in surface roughness. We make the last one the most reflective because that one will
        # be updated last and we'll be able to clearly see the other sphere's reflection of itself this way.
        surfaceRoughness = 1 - index / (@spheres.length - 1)

        if shaderClass is @constructor.ShaderClasses.PhysicalMaterial
          # We want to use three.js' Physical Material
          material = new THREE.MeshPhysicalMaterial
          material.color = color
          material.roughness = surfaceRoughness
          material.metalness = conductivity
          material.envMap = environmentMap
          material.ior = refractiveIndex
          material.refractionRatio = 1 / refractiveIndex
          # The more the material is heterogeneous, the less light it transmits.
          material.transmission = (1 - subsurfaceHeterogeneity) - conductivity
          # We approximate thickness by assuming the light ray will travel through the whole sphere.
          material.thickness = 2 * sphereRadius

        sphere.material = material

      # Render the individual environment maps from the perspective of each sphere.
      # Turn on the sun blocker if we know where the sun is.
      environmentName = @environmentName()
      @sunBlocker.visible = @constructor.ProceduralSkySettings[environmentName]?

      for sphere, index in @spheres
        # Generator will render from the origin, so we translate the scene for the sphere to be in the origin.
        @scene.position.copy(sphere.position).negate()

        # To create a slightly more accurate reflection of the most reflective sphere (accounting for sphere thickness),
        # we render the reflection from its surface. We can do this only for the edge sphere since it doesn't have
        # another sphere on the other side.
        @scene.position.z += sphereRadius if index is 4

        # Render the environment map and set it on the material.
        sphere._environmentMapRenderTarget?.dispose()
        sphere._environmentMapRenderTarget = @environmentMapGenerator.fromScene @scene, 0, 0.1, 1000
        sphere.material.envMap = sphere._environmentMapRenderTarget.texture

      # Reset the scene.
      @scene.position.set 0, 0, 0
      @sunBlocker.visible = false
