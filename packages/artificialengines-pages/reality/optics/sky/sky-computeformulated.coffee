AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

rayleighCoefficientSpectrumCache = {}

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  computeFormulated: ->
    directLightEnabled = @directLightEnabled()
    rayleighScatteringEnabled = @rayleighScatteringEnabled()
    mieScatteringEnabled = @mieScatteringEnabled()

    stepSize = @integrationStepSize() * 1e3
    atmosphereBoundsHeight = 50e3
    scaleHeight = 7994
    maxStepCount = 50

    # Prepare functions.
    getDensityRatioAtHeight = (height) ->
      Math.E ** (-height / scaleHeight)

    getMolucelarNumberDensityForGasState = (gasState) =>
      amountOfSubstance = @AirClass.getAmountOfSubstanceForState gasState
      molarConcentration = amountOfSubstance / gasState.volume
      molarConcentration * AR.AvogadroNumber

    kingCorrectionFactorSpectrum = @AirClass.getKingCorrectionFactorSpectrum()

    rayleighCoefficientFunction = AR.Optics.Scattering.getRayleighCoefficientFunction()
    rayleighPhaseFunction = AR.Optics.Scattering.getRayleighPhaseFunction()

    getRayleighCoefficientSpectrumAtHeight = (height) =>
      roundedHeight = Math.round(height / 100) * 100
      return rayleighCoefficientSpectrumCache[roundedHeight] if rayleighCoefficientSpectrumCache[roundedHeight]

      densityRatio = getDensityRatioAtHeight roundedHeight

      gasState =
        temperature: AR.StandardTemperatureAndPressure.Temperature
        pressure: AR.StandardTemperatureAndPressure.Pressure * densityRatio
        volume: 1

      refractiveIndexSpectrum = @AirClass.getRefractiveIndexSpectrumForState gasState
      molecularNumberDensity = getMolucelarNumberDensityForGasState gasState

      rayleighCoefficientSpectrumCache[roundedHeight] = new @SpectrumClass().copy new AR.Optics.Spectrum.Formulated (wavelength) =>
        refractiveIndex = refractiveIndexSpectrum.getValue wavelength
        kingCorrectionFactor = kingCorrectionFactorSpectrum.getValue wavelength

        rayleighCoefficientFunction refractiveIndex, molecularNumberDensity, wavelength, kingCorrectionFactor

      rayleighCoefficientSpectrumCache[roundedHeight]

    atmosphereBoundingSphere = new THREE.Sphere new THREE.Vector3(), @earthRadius + atmosphereBoundsHeight
    earthBoundingSphere = new THREE.Sphere new THREE.Vector3(), @earthRadius - 1

    getLengthThroughAtmosphere = (position, direction) =>
      # Intersect atmosphere bounding sphere with the ray.
      ray = new THREE.Ray position, direction
      intersection = new THREE.Vector3
      ray.intersectSphere atmosphereBoundingSphere, intersection
      intersection.sub position
      intersection.length()

    getLengthToEarth = (position, direction) =>
      # Intersect earth bounding sphere with the ray.
      ray = new THREE.Ray position, direction
      intersection = new THREE.Vector3
      ray.intersectSphere earthBoundingSphere, intersection
      intersection.sub position
      intersection.length()

    intersectsEarth = (position, direction) =>
      # Intersect Earth bounding sphere with the ray.
      ray = new THREE.Ray position, direction
      ray.intersectsSphere earthBoundingSphere

    # Prepare color calculation method.
    totalRadiance = new @SpectrumClass

    transmission = new @SpectrumClass
    totalTransmission = new @SpectrumClass

    scatteringContribution = new @SpectrumClass
    totalScatteringContribution = new @SpectrumClass

    opticalDepthSpectrum = new @SpectrumClass

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

      if rayleighScatteringEnabled
        # See how far the view ray reaches before it exits the atmosphere or hits the earth.
        if intersectsEarth viewpoint, viewRayDirection
          atmosphereRayLength = getLengthToEarth viewpoint, viewRayDirection

        else
          atmosphereRayLength = getLengthThroughAtmosphere viewpoint, viewRayDirection

        # Limit the number of steps of integration.
        minStepSize = atmosphereRayLength / maxStepCount

        # Integrate in-scattering contribution at every point along the view ray.
        totalScatteringContribution.integrateWithMidpointRule (atmosphereRayLengthToScatteringPosition) =>
          # Set parameters where we're evaluating in-scattering.
          scatteringPosition.copy(viewRayDirection).multiplyScalar(atmosphereRayLengthToScatteringPosition).add(viewpoint)
          scatteringHeight = scatteringPosition.length() - @earthRadius

          # If the sun is not visible from this sample, no (first degree) in-scattering is possible.
          if intersectsEarth scatteringPosition, sunRayDirection
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
            rayleighCoefficientSpectrum = getRayleighCoefficientSpectrumAtHeight viewRaySampleHeight

            for j in [0...opticalDepthSpectrum.array.length]
              opticalDepthSpectrum.array[j] += rayleighCoefficientSpectrum.array[j] * spacing

          # Integrate along the sun ray from the point of scattering to the exit of the atmosphere.
          sunRayLength = getLengthThroughAtmosphere scatteringPosition, sunRayDirection
          minSunRayStepSize = sunRayLength / maxStepCount
          minimumSpacing = Math.max minSunRayStepSize, stepSize

          range = sunRayLength
          n = Math.ceil range / minimumSpacing
          spacing = range / n

          for i in [0...n]
            sunRayDistance = spacing * (i + 0.5)
            sunRaySamplePosition.copy(sunRayDirection).multiplyScalar(sunRayDistance).add(scatteringPosition)
            sunRaySampleHeight = sunRaySamplePosition.length() - @earthRadius
            rayleighCoefficientSpectrum = getRayleighCoefficientSpectrumAtHeight sunRaySampleHeight

            for j in [0...opticalDepthSpectrum.array.length]
              opticalDepthSpectrum.array[j] += rayleighCoefficientSpectrum.array[j] * spacing

          # Calculate the chance of scattering.
          rayleighCoefficientSpectrumAtSamplePoint = getRayleighCoefficientSpectrumAtHeight scatteringHeight
          scatteringIntensityAtSunViewAngle = rayleighPhaseFunction sunViewAngle

          # Calculate in-scattering.
          scatteringContribution.copy(opticalDepthSpectrum).negate().exp().multiply(rayleighCoefficientSpectrumAtSamplePoint).multiplyScalar(scatteringIntensityAtSunViewAngle)
        ,
          0, atmosphereRayLength, Math.max minStepSize, stepSize

        totalTransmission.add(totalScatteringContribution)

      if directLightEnabled and Math.abs(sunViewAngle) < AR.Degrees(0.53) and not intersectsEarth viewpoint, viewRayDirection
        atmosphereRayLength = getLengthThroughAtmosphere viewpoint, viewRayDirection

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

      totalRadiance.copy(@D65EmissionSpectrum).multiply(totalTransmission)

      AS.Color.CIE1931.getXYZForSpectrum totalRadiance
