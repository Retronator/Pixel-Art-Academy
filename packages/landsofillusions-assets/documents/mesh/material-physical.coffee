AR = Artificial.Reality
LOI = LandsOfIllusions

LOI.Assets.Mesh.Material.createPhysicalMaterialParameters = (material, palette) ->
  universalMaterialOptions = @createUniversalMaterialOptions material

  color = palette.color(universalMaterialOptions.ramp, universalMaterialOptions.shade).convertSRGBToLinear()
  emissive = new THREE.Color(0).copy universalMaterialOptions.emission

  transmission = 1 - universalMaterialOptions.subsurfaceHeterogeneity
  roughness = universalMaterialOptions.surfaceRoughness

  if universalMaterialOptions.materialClass
    materialClass = AR.Chemistry.Materials.getClassForId universalMaterialOptions.materialClass

    refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
    extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

    reflectance = universalMaterialOptions.reflectance

    # Conductor color is simply the light it reflects.
    conductorColor = reflectance

    # Dielectrics reflect color that entered the material.
    dielectricColor = new THREE.Color 1 - conductorColor.r, 1 - conductorColor.g, 1 - conductorColor.b

    # Dielectrics absorb light under the surface.
    dielectricColor.multiply color

    # Choose color between the two modes (dielectric/conductor).
    if extinctionCoefficientSpectrum
      extinctionCoefficientRGB = new AR.Optics.Spectrum.RGB().copyFactor extinctionCoefficientSpectrum
      metalness = _.clamp extinctionCoefficientRGB.r(), 0, 1

    else
      metalness = 0

    color = new THREE.Color().lerpColors dielectricColor, conductorColor, metalness

    # Determine the average refractive index.
    refractiveIndexValues = new AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5().copy refractiveIndexSpectrum
    ior = _.sum(refractiveIndexValues.array) / refractiveIndexValues.array.length

  else
    ior = universalMaterialOptions.refractiveIndex.r
    metalness = universalMaterialOptions.conductivity

  color: color
  emissive: emissive
  roughness: roughness
  metalness: metalness
  ior: ior
  refractionRatio: 1 / ior
  transmission: transmission - metalness
  thickness: 1
