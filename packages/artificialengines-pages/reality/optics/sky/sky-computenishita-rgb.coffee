AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  computeNishitaRGB: ->
    directLightEnabled = @directLightEnabled()
    rayleighScatteringEnabled = @rayleighScatteringEnabled()
    mieScatteringEnabled = @mieScatteringEnabled()

    # Prepare data.
    gasStateSurface =
      temperature: AR.StandardTemperatureAndPressure.Temperature
      pressure: AR.StandardTemperatureAndPressure.Pressure
      volume: 1

    amountOfSubstanceSurface = @AirClass.getAmountOfSubstanceForState gasStateSurface
    molarConcentrationSurface = amountOfSubstanceSurface / gasStateSurface.volume
    molecularNumberDensitySurface = molarConcentrationSurface * AR.AvogadroNumber

    refractiveIndexSpectrumSurface = @AirClass.getRefractiveIndexSpectrumForState gasStateSurface

    rayleighCrossSectionFunction = AR.Optics.Scattering.getRayleighCrossSectionFunction()
    rayleighCrossSectionSpectrum = new AR.Optics.Spectrum.RGB().copyFactor new AR.Optics.Spectrum.Formulated (wavelength) =>
      refractiveIndex = refractiveIndexSpectrumSurface.getValue wavelength
      rayleighCrossSectionFunction refractiveIndex, molecularNumberDensitySurface, wavelength

    rayleighCrossSection = rayleighCrossSectionSpectrum.toVector3()
    emissionSpectrum = new AR.Optics.Spectrum.RGB().copy(@sunEmissionSpectrum).toVector3()

    rayleighPhaseFunction = AR.Optics.Scattering.getRayleighPhaseFunction()

    # Prepare color calculation method.
    totalRadiance = new THREE.Vector3

    transmission = new THREE.Vector3
    totalTransmission = new THREE.Vector3

    scatteringContribution = new THREE.Vector3

    stepSize = @integrationStepSize() * 1e3
    scaleHeight = 7994

    viewpoint = new THREE.Vector3()
    viewRayEnd = new THREE.Vector3()

    sunAngleDegrees = @sunAngleDegrees()
    sunAngle = AR.Degrees Math.round sunAngleDegrees

    sunRayDirection = new THREE.Vector3 Math.sin(sunAngle), Math.cos(sunAngle), 0
    sunRayEnd = new THREE.Vector3()

    @_computePreviewData (height, viewRayDirection) =>
      totalTransmission.set(0, 0, 0)
      scatteringContribution.set(0, 0, 0)

      viewpoint.set 0, @earthRadius + height, 0
      sunViewAngle = sunRayDirection.angleTo viewRayDirection

      intersectsEarth = @_intersectsEarth viewpoint, viewRayDirection

      if intersectsEarth
        atmosphereRayLength = @_getLengthToEarth viewpoint, viewRayDirection

      else
        atmosphereRayLength = @_getLengthThroughAtmosphere viewpoint, viewRayDirection

      viewRayStepSize = atmosphereRayLength / 6
      viewRayTotalDensityRatio = 0

      for viewRayStepCount in [0...6]
        viewRayDistance = (viewRayStepCount + 0.5) * viewRayStepSize
        viewRayEnd.copy(viewRayDirection).multiplyScalar(viewRayDistance).add(viewpoint)
        viewRayEndHeight = viewRayEnd.length() - @earthRadius
        viewRayEndDensityRatio = Math.E ** (-viewRayEndHeight / scaleHeight)
        viewRayTotalDensityRatio += viewRayEndDensityRatio / 2

        unless @_intersectsEarth viewRayEnd, sunRayDirection
          # Calculate the density ratio along the sun ray.
          if rayleighScatteringEnabled
            sunRayLength = @_getLengthThroughAtmosphere viewRayEnd, sunRayDirection

            sunRayStepSize = sunRayLength / 6
            sunRayTotalDensityRatio = 0

            for sunRayStepCount in [0...6]
              sunRayDistance = (sunRayStepCount + 0.5) * sunRayStepSize
              sunRayEnd.copy(sunRayDirection).multiplyScalar(sunRayDistance).add(viewRayEnd)
              sunRayEndHeight = sunRayEnd.length() - @earthRadius

              sunRayEndDensityRatio = Math.E ** (-sunRayEndHeight / scaleHeight)
              sunRayTotalDensityRatio += sunRayEndDensityRatio

            # Calculate contribution of scattering on this view ray segment.
            sunViewNumberDensityTimesLength = molecularNumberDensitySurface * (sunRayTotalDensityRatio * sunRayStepSize + viewRayTotalDensityRatio * viewRayStepSize)
            transmission.copy(rayleighCrossSection).multiplyScalar(-sunViewNumberDensityTimesLength).exp()
            transmission.multiplyScalar(viewRayEndDensityRatio)

            scatteringContribution.add(transmission)

        viewRayTotalDensityRatio += viewRayEndDensityRatio / 2

      if rayleighScatteringEnabled
        scatteringContribution.multiply(rayleighCrossSection).multiplyScalar(molecularNumberDensitySurface * rayleighPhaseFunction(sunViewAngle) * viewRayStepSize)
        totalTransmission.add(scatteringContribution)

      # Include direct sun.
      if directLightEnabled and Math.abs(sunViewAngle) < AR.Degrees(0.53) and not intersectsEarth
        viewRayTotalMolecularNumberDensity = molecularNumberDensitySurface * viewRayTotalDensityRatio
        transmission.copy(rayleighCrossSection).multiplyScalar(-viewRayStepSize * viewRayTotalMolecularNumberDensity).exp()
        totalTransmission.add(transmission)

      totalRadiance.copy(emissionSpectrum).multiply(totalTransmission)

      Artificial.Spectrum.Color.SRGB.getXYZForRGB
        r: totalRadiance.x
        g: totalRadiance.y
        b: totalRadiance.z
