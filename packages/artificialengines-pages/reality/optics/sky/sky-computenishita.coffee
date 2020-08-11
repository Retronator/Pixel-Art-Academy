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
    miePhaseFunction = AR.Optics.Scattering.getMiePhaseFunctionForAsymmetry 0.76

    mieScatteringCoefficient = 210e-5

    # Prepare color calculation method.
    totalRadiance = new SpectrumClass

    transmission = new SpectrumClass
    totalTransmission = new SpectrumClass

    scatteringContributionRayleigh = new SpectrumClass

    stepSize = @integrationStepSize() * 1e3
    maxHeight = 50e3
    scaleHeightRayleigh = 7994
    scaleHeightMie = 1200
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
      scatteringContributionRayleigh.clear()
      scatteringContributionMie = 0

      viewpoint.y = height
      viewRayEndHeight = viewpoint.y
      viewRayStepCount = 0

      viewRayTotalDensityRatioRayleigh = 0
      viewRayTotalDensityRatioMie = 0

      sunViewAngle = sunRayDirection.angleTo viewRayDirection

      while viewRayEndHeight < maxHeight and viewRayStepCount < maxStepCount
        viewRayStepCount++
        viewRayDistance = (viewRayStepCount - 0.5) * stepSize
        viewRayEnd.copy(viewRayDirection).multiplyScalar(viewRayDistance).add(viewpoint)
        viewRayEndRelativeToEarthCenter.subVectors(viewRayEnd, earthCenter)
        viewRayEndHeight = viewRayEndRelativeToEarthCenter.length() - @earthRadius

        viewRayEndDensityRatioRayleigh = Math.E ** (-viewRayEndHeight / scaleHeightRayleigh)
        viewRayTotalDensityRatioRayleigh += viewRayEndDensityRatioRayleigh

        viewRayEndDensityRatioMie = Math.E ** (-viewRayEndHeight / scaleHeightMie)
        viewRayTotalDensityRatioMie += viewRayEndDensityRatioMie

        # Calculate the density ratio along the sun ray.
        sunRayEndHeight = viewRayEndHeight
        sunRayStepCount = 0
        sunRayTotalDensityRatioRayleigh = 0
        sunRayTotalDensityRatioMie = 0

        if rayleighScatteringEnabled or mieScatteringEnabled
          while sunRayEndHeight < maxHeight and sunRayStepCount < maxStepCount
            sunRayStepCount++
            sunRayDistance = (sunRayStepCount - 0.5) * stepSize
            sunRayEnd.copy(sunRayDirection).multiplyScalar(sunRayDistance).add(viewRayEnd)
            sunRayEndRelativeToEarthCenter.subVectors(sunRayEnd, earthCenter)
            sunRayEndHeight = sunRayEndRelativeToEarthCenter.length() - @earthRadius

            if sunRayEndHeight < 0
              # We've gone underground, which means we must be in earth's shadow.
              sunRayTotalDensityRatioRayleigh = Number.POSITIVE_INFINITY
              sunRayTotalDensityRatioMie = Number.POSITIVE_INFINITY
              break

            if rayleighScatteringEnabled
              sunRayEndDensityRatioRayleigh = Math.E ** (-sunRayEndHeight / scaleHeightRayleigh)
              sunRayTotalDensityRatioRayleigh += sunRayEndDensityRatioRayleigh

            if mieScatteringEnabled
              sunRayEndDensityRatioMie = Math.E ** (-sunRayEndHeight / scaleHeightMie)
              sunRayTotalDensityRatioMie += sunRayEndDensityRatioMie

          # Calculate contribution of scattering on this view ray segment.
          unless (sunRayTotalDensityRatioRayleigh or sunRayTotalDensityRatioMie) is Number.POSITIVE_INFINITY
            if rayleighScatteringEnabled
              sunViewMolecularNumberDensityRayleigh = molecularNumberDensitySurface * (sunRayTotalDensityRatioRayleigh + viewRayTotalDensityRatioRayleigh)
              transmission.copy(rayleighCrossSectionSpectrum).multiplyScalar(-stepSize * sunViewMolecularNumberDensityRayleigh).exp()
              transmission.multiplyScalar(molecularNumberDensitySurface * viewRayEndDensityRatioRayleigh)
              scatteringContributionRayleigh.add(transmission)

            if mieScatteringEnabled
              sunViewMieScatteringCoefficient = mieScatteringCoefficient * (sunRayTotalDensityRatioMie + viewRayTotalDensityRatioMie)
              transmissionMie = Math.E ** (-stepSize * sunViewMieScatteringCoefficient) * sunViewMieScatteringCoefficient
              scatteringContributionMie += transmissionMie

      if rayleighScatteringEnabled
        scatteringContributionRayleigh.multiply(rayleighCrossSectionSpectrum).multiplyScalar(rayleighPhaseFunction(sunViewAngle) * stepSize)
        totalTransmission.add(scatteringContributionRayleigh)

      if mieScatteringEnabled
        totalTransmission.addConstant scatteringContributionMie * miePhaseFunction(sunViewAngle) * stepSize

      # Include direct sun.
      if directLightEnabled and Math.abs(sunViewAngle) < AR.Degrees 0.53
        viewRayTotalMolecularNumberDensityRayleigh = molecularNumberDensitySurface * viewRayTotalDensityRatioRayleigh
        viewRayMieScatteringCoefficient = mieScatteringCoefficient * viewRayTotalDensityRatioMie
        transmission.copy(rayleighCrossSectionSpectrum).multiplyScalar(viewRayTotalMolecularNumberDensityRayleigh).addConstant(viewRayMieScatteringCoefficient).multiplyScalar(-stepSize).exp()
        totalTransmission.add(transmission)

      totalRadiance.copy(@SunEmissionSpectrum).multiply(totalTransmission)

      AS.Color.CIE1931.getXYZForSpectrum totalRadiance
