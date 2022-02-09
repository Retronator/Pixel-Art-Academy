AM = Artificial.Mirage
AR = Artificial.Reality
AS = Artificial.Spectrum

class AR.Pages.Chemistry.Materials.Shaders extends AR.Pages.Chemistry.Materials.Shaders
  @register 'Artificial.Reality.Pages.Chemistry.Materials.Shaders'

  onCreated: ->
    super arguments...

    # Create a palette with only white color.
    @paletteTexture = new LOI.Engine.Textures.Palette

    @autorun (computation) =>
      return unless palette = LOI.palette()
      hue = @hue()
      shade = @shade()

      @paletteTexture.update
        ramps: [
          shades: [
            palette.color hue, shade
          ]
        ]

    # Determine reflectance at normal incidence (specular color).
    @reflectance = new ComputedField =>
      materialClass = @materialClass()

      refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
      extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

      reflectanceSpectrum = new AR.Optics.Spectrum.Formulated (wavelength) =>
        refractiveIndex = refractiveIndexSpectrum.getValue wavelength
        extinctionCoefficient = extinctionCoefficientSpectrum?.getValue wavelength
        AR.Optics.FresnelEquations.getReflectance 0, 1, refractiveIndex, 0, extinctionCoefficient

      new AR.Optics.Spectrum.RGB().copyFactor(reflectanceSpectrum).toObject()
      
    @conductivity = new ComputedField =>
      materialClass = @materialClass()

      # Determine how conductive this material is.
      if extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()
        extinctionCoefficientRGB = new AR.Optics.Spectrum.RGB().copyFactor extinctionCoefficientSpectrum
        conductivity = _.clamp extinctionCoefficientRGB.r(), 0, 1

      else
        conductivity = 0

    # Create the 5 material properties.
    @materialPropertiesTexture = new LOI.Engine.Textures.MaterialProperties

    @autorun (computation) =>
      materialClass = @materialClass()

      refractiveIndexRGB = new AR.Optics.Spectrum.RGB().copyFactor materialClass.getRefractiveIndexSpectrum()

      material =
        ramp: 0
        shade: 0
        dither: 0
        reflectance: @reflectance()
        refractiveIndex: refractiveIndexRGB.toObject()
        subsurfaceHeterogeneity: @subsurfaceHeterogeneity()
        conductivity: @conductivity()

      materials = for sphere, index in @spheres
        _.defaultsDeep
          surfaceRoughness: 1 - index / (@spheres.length - 1)
        ,
          material

      materialProperties = (materialIndex: index for sphere, index in @spheres)

      @materialPropertiesTexture.update
        getAll: => materialProperties
        mesh: materials: getAll: => materials

      @sceneUpdated.changed()

    @universalMaterialOptions = new ComputedField =>
      mesh:
        paletteTexture: @paletteTexture
        materialProperties:
          texture: @materialPropertiesTexture
        lightmapAreaProperties:
          texture: null

    # Reactively set chosen material and shader on the spheres.
    @autorun (computation) =>
      shaderClass = @shaderClass()
      environmentMap = @environmentMap()

      # Note: We want to react to material class changes so that reflections get re-rendered, even if
      # we're using the universal material, which wouldn't otherwise require re-creation of the material.
      materialClass = @materialClass()

      if shaderClass is @constructor.ShaderClasses.PhysicalMaterial
        # Conductor color is simply the light it reflects.
        conductorColor = @reflectance()

        # Dielectrics reflect color that entered the material.
        dielectricColor = new THREE.Color 1 - conductorColor.r, 1 - conductorColor.g, 1 - conductorColor.b

        # Dielectrics absorb light under the surface.
        return unless palette = LOI.palette()

        hue = @hue()
        shade = @shade()
        subsurfaceColor = palette.color(hue, shade).convertSRGBToLinear()
        dielectricColor.multiply subsurfaceColor

        # Choose color between the two modes (dielectric/conductor).
        color = new THREE.Color().lerpColors dielectricColor, conductorColor, @conductivity()

        # Determine the average refractive index.
        refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
        refractiveIndexValues = new AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5().copy refractiveIndexSpectrum
        refractiveIndex = _.sum(refractiveIndexValues.array) / refractiveIndexValues.array.length

        # Get structure parameters.
        subsurfaceHeterogeneity = @subsurfaceHeterogeneity()
        conductivity = @conductivity()

        # Create materials on the spheres.
        for sphere, index in @spheres
          # The spheres differ in surface roughness. We make the last one the most reflective because that one will
          # be updated last and we'll be able to clearly see the other sphere's reflection of itself this way.
          surfaceRoughness = 1 - index / (@spheres.length - 1)

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
          material.thickness = 2 * @sphereRadius

          sphere.material = material

      else
        # Create materials on the spheres.
        for sphere, index in @spheres
          material = new LOI.Engine.Materials.UniversalMaterial @universalMaterialOptions()
          material.uniforms.envMap.value = environmentMap
          material.envMap = environmentMap
          sphere.material = material

      @sceneUpdated.changed()

    @autorun (computation) =>
      @sceneUpdated.depend()

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
        @scene.position.z += @sphereRadius if index is 4

        # Render the environment map and set it on the material.
        sphere._environmentMapRenderTarget?.dispose()
        sphere._environmentMapRenderTarget = @environmentMapGenerator.fromScene @scene, 0, 0.1, 1000
        sphere.material.envMap = sphere._environmentMapRenderTarget.texture
        sphere.material.uniforms?.envMap.value = sphere.material.envMap

      # Reset the scene.
      @scene.position.set 0, 0, 0
      @sunBlocker.visible = false
