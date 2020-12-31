AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

SpectrumClass = AR.Optics.Spectrum.XYZ
D65EmissionSpectrumXYZ = null
rayleighCoefficientSpectrumCacheXYZ = []

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  computeFormulatedXYZ: ->
    D65EmissionSpectrumXYZ ?= new SpectrumClass().copy @SunEmissionSpectrum

    @_computeFormulatedFast SpectrumClass, D65EmissionSpectrumXYZ, rayleighCoefficientSpectrumCacheXYZ

  _computeFormulatedFast: (SpectrumClass, D65EmissionSpectrum, rayleighCoefficientSpectrumCache) ->
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

      rayleighCoefficientSpectrumCache[heightHash] = new SpectrumClass().copyFactor new AR.Optics.Spectrum.Formulated (wavelength) =>
        refractiveIndex = refractiveIndexSpectrum.getValue wavelength
        kingCorrectionFactor = kingCorrectionFactorSpectrum.getValue wavelength

        rayleighCoefficientFunction refractiveIndex, molecularNumberDensity, wavelength, kingCorrectionFactor

      rayleighCoefficientSpectrumCache[heightHash]

    getMieCoefficientAtHeight = (height) =>
      densityRatio = getMieDensityRatioAtHeight height
      21e-6 * densityRatio

    # Prepare color calculation method.
    totalRadiance = new SpectrumClass

    transmission = new SpectrumClass
    totalTransmission = new SpectrumClass

    scatteringContribution = new SpectrumClass
    totalScatteringContribution = new SpectrumClass

    viewRayOpticalDepthSpectrum = new SpectrumClass
    viewRayOpticalDepthSpectrumArray = viewRayOpticalDepthSpectrum.array

    opticalDepthSpectrum = new SpectrumClass
    opticalDepthSpectrumArray = opticalDepthSpectrum.array

    viewpoint = new THREE.Vector3()
    scatteringPosition = new THREE.Vector3()
    viewRayDirectionQuarterStep = new THREE.Vector3()
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
        viewRayRange = atmosphereRayLength
        viewRayMinimumSpacing = Math.max minStepSize, stepSize
        viewRayDivisions = Math.ceil viewRayRange / viewRayMinimumSpacing
        viewRaySpacing = viewRayRange / viewRayDivisions

        viewRayDirectionQuarterStep.copy(viewRayDirection).multiplyScalar viewRaySpacing * 0.25
        scatteringPosition.copy viewpoint

        totalScatteringContribution.clear()
        viewRayOpticalDepthSpectrum.clear()

        for viewRayDivision in [0...viewRayDivisions]
          # Set parameters where we're evaluating optical depth.
          scatteringPosition.add viewRayDirectionQuarterStep
          opticalDepthHeight = scatteringPosition.length() - @earthRadius

          # Calculate optical depth.
          rayleighCoefficientSpectrumArray = getRayleighCoefficientSpectrumAtHeight(opticalDepthHeight).array if rayleighScatteringEnabled
          mieCoefficient = getMieCoefficientAtHeight opticalDepthHeight if mieScatteringEnabled

          for j in [0...viewRayOpticalDepthSpectrumArray.length]
            viewRayOpticalDepthSpectrumArray[j] += rayleighCoefficientSpectrumArray[j] * viewRaySpacing * 0.5 if rayleighScatteringEnabled
            viewRayOpticalDepthSpectrumArray[j] += mieCoefficient * viewRaySpacing * 0.5 if mieScatteringEnabled

          # Set parameters where we're evaluating in-scattering.
          scatteringPosition.add viewRayDirectionQuarterStep

          # If the sun is not visible from this sample, no (first degree) in-scattering is possible.
          unless @_intersectsEarth scatteringPosition, sunRayDirection
            # Calculate total optical depth including along the sun ray.
            opticalDepthSpectrum.copy viewRayOpticalDepthSpectrum

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
              rayleighCoefficientSpectrumArray = getRayleighCoefficientSpectrumAtHeight(sunRaySampleHeight).array if rayleighScatteringEnabled
              mieCoefficient = getMieCoefficientAtHeight sunRaySampleHeight if mieScatteringEnabled

              for j in [0...opticalDepthSpectrumArray.length]
                opticalDepthSpectrumArray[j] += rayleighCoefficientSpectrumArray[j] * spacing if rayleighScatteringEnabled
                opticalDepthSpectrumArray[j] += mieCoefficient * spacing if mieScatteringEnabled

            # Calculate the chance of scattering.
            scatteringHeight = scatteringPosition.length() - @earthRadius

            if rayleighScatteringEnabled
              rayleighCoefficientSpectrumAtSamplePoint = getRayleighCoefficientSpectrumAtHeight scatteringHeight
              rayleighScatteringIntensityAtSunViewAngle = rayleighPhaseFunction sunViewAngle

            if mieScatteringEnabled
              mieCoefficientAtSamplePoint = getMieCoefficientAtHeight scatteringHeight
              mieScatteringIntensityAtSunViewAngle = miePhaseFunction sunViewAngle

            # Calculate in-scattering.
            if rayleighScatteringEnabled
              scatteringContribution.copy(opticalDepthSpectrum).negate().exp().multiply(rayleighCoefficientSpectrumAtSamplePoint).multiplyScalar(rayleighScatteringIntensityAtSunViewAngle)
              totalScatteringContribution.add scatteringContribution

            if mieScatteringEnabled
              scatteringContribution.copy(opticalDepthSpectrum).negate().exp().multiplyScalar(mieCoefficientAtSamplePoint * mieScatteringIntensityAtSunViewAngle)
              totalScatteringContribution.add scatteringContribution

          # Set parameters where we're evaluating optical depth on the other side.
          scatteringPosition.add viewRayDirectionQuarterStep
          opticalDepthHeight = scatteringPosition.length() - @earthRadius

          # Calculate optical depth.
          rayleighCoefficientSpectrumArray = getRayleighCoefficientSpectrumAtHeight(opticalDepthHeight).array if rayleighScatteringEnabled
          mieCoefficient = getMieCoefficientAtHeight opticalDepthHeight if mieScatteringEnabled

          for j in [0...viewRayOpticalDepthSpectrumArray.length]
            viewRayOpticalDepthSpectrumArray[j] += rayleighCoefficientSpectrumArray[j] * viewRaySpacing * 0.5 if rayleighScatteringEnabled
            viewRayOpticalDepthSpectrumArray[j] += mieCoefficient * viewRaySpacing * 0.5 if mieScatteringEnabled

          # Set parameters to end of interval.
          scatteringPosition.add viewRayDirectionQuarterStep

        for i in [0...totalScatteringContribution.array.length]
          totalScatteringContribution.array[i] *= viewRaySpacing

        totalTransmission.add(totalScatteringContribution)

      if directLightEnabled and Math.abs(sunViewAngle) < AR.Degrees(0.53) and not @_intersectsEarth viewpoint, viewRayDirection
        atmosphereRayLength = @_getLengthThroughAtmosphere viewpoint, viewRayDirection

        for coordinate in [0..2]
          opticalDepth = AP.Integration.integrateWithMidpointRule (distance) =>
            scatteringPosition.copy(viewRayDirection).multiplyScalar(distance).add(viewpoint)
            sampleHeight = scatteringPosition.length() - @earthRadius
            rayleighCoefficientSpectrum = getRayleighCoefficientSpectrumAtHeight sampleHeight
            mieCoefficient = getMieCoefficientAtHeight sampleHeight
            rayleighCoefficientSpectrum.array[coordinate] + mieCoefficient
          ,
            0, atmosphereRayLength, stepSize

          transmission.array[coordinate] = Math.E ** (-opticalDepth)

        totalTransmission.add(transmission)

      totalRadiance.copy(D65EmissionSpectrum).multiply(totalTransmission).toXYZ()
