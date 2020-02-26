AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

SpectrumClass = AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  computeNishita: ->
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
    rayleighCrossSectionSpectrum = new SpectrumClass().copy new AR.Optics.Spectrum.Formulated (wavelength) =>
      refractiveIndex = refractiveIndexSpectrumSurface.getValue wavelength
      rayleighCrossSectionFunction refractiveIndex, molecularNumberDensitySurface, wavelength

    rayleighPhaseFunction = AR.Optics.Scattering.getRayleighPhaseFunction()

    # Prepare color calculation method.
    totalRadiance = new SpectrumClass

    transmission = new SpectrumClass
    totalTransmission = new SpectrumClass

    scatteringContribution = new SpectrumClass

    stepSize = @integrationStepSize() * 1e3
    maxHeight = 50e3
    scaleHeight = 7994
    maxStepCount = 500

    viewpoint = new THREE.Vector3()
    earthCenter = new THREE.Vector3 0, -@earthRadius, 0

    viewRayEnd = new THREE.Vector3()
    viewRayEndRelativeToEarthCenter = new THREE.Vector3()

    sunAngleDegrees = @sunAngleDegrees()
    sunAngle = AR.Degrees Math.round sunAngleDegrees

    sunRayDirection = new THREE.Vector3 Math.sin(sunAngle), Math.cos(sunAngle), 0
    sunRayEnd = new THREE.Vector3()
    sunRayEndRelativeToEarthCenter = new THREE.Vector3()

    @_computePreviewData (height, viewRayDirection) =>
      totalTransmission.clear()
      scatteringContribution.clear()

      viewpoint.y = height
      viewRayEndHeight = viewpoint.y
      viewRayStepCount = 0

      viewRayTotalDensityRatio = 0

      sunViewAngle = sunRayDirection.angleTo viewRayDirection

      while viewRayEndHeight < maxHeight and viewRayStepCount < maxStepCount
        viewRayStepCount++
        viewRayDistance = (viewRayStepCount - 0.5) * stepSize
        viewRayEnd.copy(viewRayDirection).multiplyScalar(viewRayDistance).add(viewpoint)
        viewRayEndRelativeToEarthCenter.subVectors(viewRayEnd, earthCenter)
        viewRayEndHeight = viewRayEndRelativeToEarthCenter.length() - @earthRadius
        viewRayEndDensityRatio = Math.E ** (-viewRayEndHeight / scaleHeight)
        viewRayTotalDensityRatio += viewRayEndDensityRatio

        # Calculate the density ratio along the sun ray.
        sunRayEndHeight = viewRayEndHeight
        sunRayStepCount = 0
        sunRayTotalDensityRatio = 0

        if rayleighScatteringEnabled
          while sunRayEndHeight < maxHeight and sunRayStepCount < maxStepCount
            sunRayStepCount++
            sunRayDistance = (sunRayStepCount - 0.5) * stepSize
            sunRayEnd.copy(sunRayDirection).multiplyScalar(sunRayDistance).add(viewRayEnd)
            sunRayEndRelativeToEarthCenter.subVectors(sunRayEnd, earthCenter)
            sunRayEndHeight = sunRayEndRelativeToEarthCenter.length() - @earthRadius

            if sunRayEndHeight < 0
              # We've gone underground, which means we must be in earth's shadow.
              sunRayTotalDensityRatio = Number.POSITIVE_INFINITY
              break

            sunRayEndDensityRatio = Math.E ** (-sunRayEndHeight / scaleHeight)
            sunRayTotalDensityRatio += sunRayEndDensityRatio

          # Calculate contribution of scattering on this view ray segment.
          unless sunRayTotalDensityRatio is Number.POSITIVE_INFINITY
            sunViewMolecularNumberDensity = molecularNumberDensitySurface * (sunRayTotalDensityRatio + viewRayTotalDensityRatio)
            transmission.copy(rayleighCrossSectionSpectrum).multiplyScalar(-stepSize * sunViewMolecularNumberDensity).exp()
            transmission.multiplyScalar(molecularNumberDensitySurface * viewRayEndDensityRatio)
            scatteringContribution.add(transmission)

      if rayleighScatteringEnabled
        scatteringContribution.multiply(rayleighCrossSectionSpectrum).multiplyScalar(rayleighPhaseFunction(sunViewAngle) * stepSize)
        totalTransmission.add(scatteringContribution)

      viewRayTotalMolecularNumberDensity = molecularNumberDensitySurface * viewRayTotalDensityRatio

      # Include direct sun.
      if directLightEnabled and Math.abs(sunViewAngle) < AR.Degrees 0.53
        transmission.copy(rayleighCrossSectionSpectrum).multiplyScalar(-stepSize * viewRayTotalMolecularNumberDensity).exp()
        totalTransmission.add(transmission)

      totalRadiance.copy(@D65EmissionSpectrum).multiply(totalTransmission)

      AS.Color.CIE1931.getXYZForSpectrum totalRadiance
