AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.Engine.Skydome.Procedural.RenderMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    RGBSpectrum = AR.Optics.Spectrum.RGB

    # Prepare planet properties.
    planetRadius = 6371e3

    # Prepare atmosphere properties.
    atmosphereBoundsHeight = 50e3
    atmosphereScaleHeight = 7994

    AtmosphereClass = AR.Chemistry.Materials.Mixtures.Air.DryMixture

    gasStateSurface =
      temperature: AR.StandardTemperatureAndPressure.Temperature
      pressure: AR.StandardTemperatureAndPressure.Pressure
      volume: 1

    amountOfSubstanceSurface = AtmosphereClass.getAmountOfSubstanceForState gasStateSurface
    molarConcentrationSurface = amountOfSubstanceSurface / gasStateSurface.volume
    molecularNumberDensitySurface = molarConcentrationSurface * AR.AvogadroNumber

    refractiveIndexSpectrumSurface = AtmosphereClass.getRefractiveIndexSpectrumForState gasStateSurface
    kingCorrectionFactorSpectrum = AtmosphereClass.getKingCorrectionFactorSpectrum()

    rayleighCrossSectionFunction = AR.Optics.Scattering.getRayleighCrossSectionFunction()
    rayleighCrossSectionSpectrum = new RGBSpectrum().copyFactor new AR.Optics.Spectrum.Formulated (wavelength) =>
      refractiveIndex = refractiveIndexSpectrumSurface.getValue wavelength
      kingCorrectionFactor = kingCorrectionFactorSpectrum.getValue wavelength

      rayleighCrossSectionFunction refractiveIndex, molecularNumberDensitySurface, wavelength, kingCorrectionFactor

    atmosphereRayleighCrossSection = rayleighCrossSectionSpectrum.toVector3()

    # Prepare star properties.
    starAngularSizeHalf = 0.004625

    starEmissionSpectrum = AR.Chemistry.Materials.Mixtures.Stars.Sun.getEmissionSpectrumForTemperature 5778
    starEmission = new RGBSpectrum().copy(starEmissionSpectrum).toVector3()

    # Create the shader.
    parameters =
      blending: THREE.NoBlending

      uniforms:
        # Planet
        planetRadius:
          value: planetRadius
        planetRadiusSquared:
          value: planetRadius ** 2

        # Atmosphere
        atmosphereBoundsHeight:
          value: atmosphereBoundsHeight
        atmosphereBoundsRadiusSquared:
          value: (planetRadius + atmosphereBoundsHeight) ** 2
        atmosphereScaleHeight:
          value: atmosphereScaleHeight
        atmosphereRayleighCrossSection:
          value: atmosphereRayleighCrossSection
        atmosphereMolecularNumberDensitySurface:
          value: molecularNumberDensitySurface

        # Star
        starDirection:
          value: new THREE.Vector3 0, -1, 0
        starAngularSizeHalf:
          value: starAngularSizeHalf
        starEmission:
          value: starEmission

      vertexShader: '#include <LandsOfIllusions.Engine.Skydome.Procedural.RenderMaterial.vertex>'
      fragmentShader: options.fragmentShader or '#include <LandsOfIllusions.Engine.Skydome.Procedural.RenderMaterial.fragment>'

    if options?.scatteringMap
      parameters.uniforms.scatteringMap = value: options.scatteringMap

    super parameters
    @options = options
