AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

SpectrumClass = AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5
rayleighCoefficientSpectrumCache = {}

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  computeFormulated: ->
    directLightEnabled = @directLightEnabled()
    rayleighScatteringEnabled = @rayleighScatteringEnabled()
    mieScatteringEnabled = @mieScatteringEnabled()

    stepSize = @integrationStepSize() * 1e3
    scaleHeightRayleigh = 7994
    scaleHeightMie = 1200
    maxStepCount = 20

    # Prepare functions.
    getRayleighDensityRatioAtHeight = (height) ->
      Math.E ** (-height / scaleHeightRayleigh)

    getMieDensityRatioAtHeight = (height) ->
      Math.E ** (-height / scaleHeightMie)

    getMolucelarNumberDensityForGasState = (gasState) =>
      amountOfSubstance = @AirClass.getAmountOfSubstanceForState gasState
      molarConcentration = amountOfSubstance / gasState.volume
      molarConcentration * AR.AvogadroNumber

    kingCorrectionFactorSpectrum = @AirClass.getKingCorrectionFactorSpectrum()

    rayleighCoefficientFunction = AR.Optics.Scattering.getRayleighCoefficientFunction()
    rayleighPhaseFunction = AR.Optics.Scattering.getRayleighPhaseFunction()

    miePhaseFunction = AR.Optics.Scattering.getMiePhaseFunctionForAsymmetry 0.76

    getRayleighCoefficientSpectrumAtHeight = (height) =>
      heightHash = height >> 7
      rayleighCoefficientSpectrum = rayleighCoefficientSpectrumCache[heightHash]
      return rayleighCoefficientSpectrum if rayleighCoefficientSpectrum

      roundedHeight = heightHash << 7

      densityRatio = getRayleighDensityRatioAtHeight roundedHeight

      gasState =
        temperature: AR.StandardTemperatureAndPressure.Temperature
        pressure: AR.StandardTemperatureAndPressure.Pressure * densityRatio
        volume: 1

      refractiveIndexSpectrum = @AirClass.getRefractiveIndexSpectrumForState gasState
      molecularNumberDensity = getMolucelarNumberDensityForGasState gasState

      rayleighCoefficientSpectrumCache[heightHash] = new SpectrumClass().copy new AR.Optics.Spectrum.Formulated (wavelength) =>
        refractiveIndex = refractiveIndexSpectrum.getValue wavelength
        kingCorrectionFactor = kingCorrectionFactorSpectrum.getValue wavelength

        rayleighCoefficientFunction refractiveIndex, molecularNumberDensity, wavelength, kingCorrectionFactor

      rayleighCoefficientSpectrumCache[heightHash]

    getMieCoefficientSpectrumAtHeight = (height) =>
      densityRatio = getMieDensityRatioAtHeight height
      new SpectrumClass().setConstant 21e-6 * densityRatio

    # Prepare color calculation method.
    totalRadiance = new SpectrumClass

    transmission = new SpectrumClass
    totalTransmission = new SpectrumClass

    scatteringContribution = new SpectrumClass
    scatteringContributionRayleigh = new SpectrumClass
    scatteringContributionMie = new SpectrumClass
    totalScatteringContribution = new SpectrumClass

    opticalDepthSpectrum = new SpectrumClass

    viewpoint = new THREE.Vector3()
    scatteringPosition = new THREE.Vector3()
    viewRaySamplePosition = new THREE.Vector3()
    sunRaySamplePosition = new THREE.Vector3()

    sunAngleDegrees = @sunAngleDegrees()
    sunAngle = AR.Degrees Math.round sunAngleDegrees

    sunRayDirection = new THREE.Vector3 Math.sin(sunAngle), Math.cos(sunAngle), 0

    @_computePreviewData (height, viewRayDirection) =>
      # Calculate total transmission of the sun through the atmosphere (direct and scattered).
      totalTransmission.clear()

      # Set viewpoint parameters.
      viewpoint.set 0, @earthRadius + height, 0
      sunViewAngle = sunRayDirection.angleTo viewRayDirection

      if rayleighScatteringEnabled or mieScatteringEnabled
        # See how far the view ray reaches before it exits the atmosphere or hits the earth.
        if @_intersectsEarth viewpoint, viewRayDirection
          atmosphereRayLength = @_getLengthToEarth viewpoint, viewRayDirection

        else
          atmosphereRayLength = @_getLengthThroughAtmosphere viewpoint, viewRayDirection

        # Limit the number of steps of integration.
        minStepSize = atmosphereRayLength / maxStepCount

        # Integrate in-scattering contribution at every point along the view ray.
        totalScatteringContribution.integrateWithMidpointRule (atmosphereRayLengthToScatteringPosition) =>
          # Set parameters where we're evaluating in-scattering.
          scatteringPosition.copy(viewRayDirection).multiplyScalar(atmosphereRayLengthToScatteringPosition).add(viewpoint)
          scatteringHeight = scatteringPosition.length() - @earthRadius

          # If the sun is not visible from this sample, no (first degree) in-scattering is possible.
          if @_intersectsEarth scatteringPosition, sunRayDirection
            scatteringContribution.clear()
            return scatteringContribution

          # Calculate optical depth.
          opticalDepthSpectrum.clear()

          # Integrate along the view ray to the point of scattering.
          minAtmosphereStepSize = atmosphereRayLengthToScatteringPosition / maxStepCount
          minimumSpacing = Math.max minAtmosphereStepSize, stepSize

          range = atmosphereRayLengthToScatteringPosition
          n = Math.ceil range / minimumSpacing
          spacing = range / n

          for i in [0...n]
            viewRayDistance = spacing * (i + 0.5)
            viewRaySamplePosition.copy(viewRayDirection).multiplyScalar(viewRayDistance).add(viewpoint)
            viewRaySampleHeight = viewRaySamplePosition.length() - @earthRadius
            rayleighCoefficientSpectrum = getRayleighCoefficientSpectrumAtHeight viewRaySampleHeight if rayleighScatteringEnabled
            mieCoefficientSpectrum = getMieCoefficientSpectrumAtHeight viewRaySampleHeight if mieScatteringEnabled

            for j in [0...opticalDepthSpectrum.array.length]
              opticalDepthSpectrum.array[j] += rayleighCoefficientSpectrum.array[j] * spacing if rayleighScatteringEnabled
              opticalDepthSpectrum.array[j] += mieCoefficientSpectrum.array[j] * spacing if mieScatteringEnabled

          # Integrate along the sun ray from the point of scattering to the exit of the atmosphere.
          sunRayLength = @_getLengthThroughAtmosphere scatteringPosition, sunRayDirection
          minSunRayStepSize = sunRayLength / maxStepCount
          minimumSpacing = Math.max minSunRayStepSize, stepSize

          range = sunRayLength
          n = Math.ceil range / minimumSpacing
          spacing = range / n

          for i in [0...n]
            sunRayDistance = spacing * (i + 0.5)
            sunRaySamplePosition.copy(sunRayDirection).multiplyScalar(sunRayDistance).add(scatteringPosition)
            sunRaySampleHeight = sunRaySamplePosition.length() - @earthRadius
            rayleighCoefficientSpectrum = getRayleighCoefficientSpectrumAtHeight sunRaySampleHeight if rayleighScatteringEnabled
            mieCoefficientSpectrum = getMieCoefficientSpectrumAtHeight sunRaySampleHeight if mieScatteringEnabled

            for j in [0...opticalDepthSpectrum.array.length]
              opticalDepthSpectrum.array[j] += rayleighCoefficientSpectrum.array[j] * spacing if rayleighScatteringEnabled
              opticalDepthSpectrum.array[j] += mieCoefficientSpectrum.array[j] * spacing if mieScatteringEnabled

          # Calculate the chance of scattering.
          if rayleighScatteringEnabled
            rayleighCoefficientSpectrumAtSamplePoint = getRayleighCoefficientSpectrumAtHeight scatteringHeight
            scatteringIntensityAtSunViewAngleRayleigh = rayleighPhaseFunction sunViewAngle

          if mieScatteringEnabled
            mieCoefficientSpectrumAtSamplePoint = getMieCoefficientSpectrumAtHeight scatteringHeight
            scatteringIntensityAtSunViewAngleMie = miePhaseFunction sunViewAngle

          # Calculate in-scattering.
          scatteringContribution.clear()

          if rayleighScatteringEnabled
            scatteringContributionRayleigh.copy(opticalDepthSpectrum).negate().exp().multiply(rayleighCoefficientSpectrumAtSamplePoint).multiplyScalar(scatteringIntensityAtSunViewAngleRayleigh)
            scatteringContribution.add scatteringContributionRayleigh

          if mieScatteringEnabled
            scatteringContributionMie.copy(opticalDepthSpectrum).negate().exp().multiply(mieCoefficientSpectrumAtSamplePoint).multiplyScalar(scatteringIntensityAtSunViewAngleMie)
            scatteringContribution.add scatteringContributionMie

          scatteringContribution
        ,
          0, atmosphereRayLength, Math.max minStepSize, stepSize

        totalTransmission.add(totalScatteringContribution)

      if directLightEnabled and Math.abs(sunViewAngle) < AR.Degrees(0.53) and not @_intersectsEarth viewpoint, viewRayDirection
        atmosphereRayLength = @_getLengthThroughAtmosphere viewpoint, viewRayDirection

        transmission = new AR.Optics.Spectrum.Formulated (wavelength) =>
          opticalDepth = AP.Integration.integrateWithMidpointRule (distance) =>
            scatteringPosition.copy(viewRayDirection).multiplyScalar(distance).add(viewpoint)
            sampleHeight = scatteringPosition.length() - @earthRadius
            rayleighCoefficientSpectrum = getRayleighCoefficientSpectrumAtHeight sampleHeight
            rayleighCoefficientSpectrum.getValue wavelength
          ,
            0, atmosphereRayLength, stepSize

          Math.E ** (-opticalDepth)

        totalTransmission.add(transmission)

      totalRadiance.copy(@SunEmissionSpectrum).multiply(totalTransmission)

      AS.Color.CIE1931.getXYZForSpectrum totalRadiance
