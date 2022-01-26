AR = Artificial.Reality
LOI = LandsOfIllusions

class LOI.Engine.Skydome.Procedural.RenderMaterial extends THREE.RawShaderMaterial
  constructor: (options) ->
    # Set defaults to Earth and Sun.
    _.defaultsDeep options,
      planet:
        radius: 6371e3

      atmosphere:
        class: AR.Chemistry.Materials.Mixtures.Air.DryMixture
        boundsHeight: 50e3
        rayleighScaleHeight: 7994
        mieScaleHeight: 1200
        mieScatteringCoefficient: 5e-6
        mieAsymmetry: 0.95
        surface:
          temperature: AR.StandardTemperatureAndPressure.Temperature
          pressure: AR.StandardTemperatureAndPressure.Pressure

      # Star
      star:
        angularSize: 0.00931
        class: AR.Chemistry.Materials.Mixtures.Stars.Sun
        temperature: 5778

      # Output
      intensityFactors:
        scattering: 1
        star: 1

    RGBSpectrum = AR.Optics.Spectrum.RGB

    gasStateSurface =
      temperature: options.atmosphere.surface.temperature
      pressure: options.atmosphere.surface.pressure
      volume: 1

    amountOfSubstanceSurface = options.atmosphere.class.getAmountOfSubstanceForState gasStateSurface
    molarConcentrationSurface = amountOfSubstanceSurface / gasStateSurface.volume
    molecularNumberDensitySurface = molarConcentrationSurface * AR.AvogadroNumber

    refractiveIndexSpectrumSurface = options.atmosphere.class.getRefractiveIndexSpectrumForState gasStateSurface
    kingCorrectionFactorSpectrum = options.atmosphere.class.getKingCorrectionFactorSpectrum()

    rayleighCrossSectionFunction = AR.Optics.Scattering.getRayleighCrossSectionFunction()
    rayleighCrossSectionSpectrum = new RGBSpectrum().copyFactor new AR.Optics.Spectrum.Formulated (wavelength) =>
      refractiveIndex = refractiveIndexSpectrumSurface.getValue wavelength
      kingCorrectionFactor = kingCorrectionFactorSpectrum.getValue wavelength

      rayleighCrossSectionFunction refractiveIndex, molecularNumberDensitySurface, wavelength, kingCorrectionFactor

    atmosphereRayleighCrossSection = rayleighCrossSectionSpectrum.toVector3()
    atmosphereRayleighScatteringCoefficientSurface = atmosphereRayleighCrossSection.clone().multiplyScalar molecularNumberDensitySurface

    starEmissionSpectrum = options.star.class.getEmissionSpectrumForTemperature options.star.temperature
    starEmission = new RGBSpectrum().copy(starEmissionSpectrum).toVector3().multiplyScalar(1 / 255)

    # Create the shader.
    parameters =
      blending: THREE.NoBlending

      uniforms:
        # Planet
        planetRadius:
          value: options.planet.radius
        planetRadiusSquared:
          value: options.planet.radius ** 2

        # Atmosphere
        atmosphereBoundsHeight:
          value: options.atmosphere.boundsHeight
        atmosphereBoundsRadiusSquared:
          value: (options.planet.radius + options.atmosphere.boundsHeight) ** 2

        atmosphereRayleighScaleHeight:
          value: options.atmosphere.rayleighScaleHeight
        atmosphereRayleighScatteringCoefficientSurface:
          value: atmosphereRayleighScatteringCoefficientSurface

        atmosphereMieScaleHeight:
          value: options.atmosphere.mieScaleHeight
        atmosphereMieScatteringCoefficientSurface:
          value: options.atmosphere.mieScatteringCoefficient
        atmosphereMieAsymmetry:
          value: options.atmosphere.mieAsymmetry

        # Star
        starDirection:
          value: new THREE.Vector3 0, -1, 0
        starAngularSizeHalf:
          value: options.star.angularSize / 2
        starEmission:
          value: starEmission
        starFactor:
          value: options.intensityFactors.star
        scatteringFactor:
          value: options.intensityFactors.scattering

      vertexShader: '#include <LandsOfIllusions.Engine.Skydome.Procedural.RenderMaterial.vertex>'
      fragmentShader: options.fragmentShader or '#include <LandsOfIllusions.Engine.Skydome.Procedural.RenderMaterial.fragment>'

    if options?.scatteringMap
      parameters.uniforms.scatteringMap = value: options.scatteringMap

    super parameters
    @options = options
