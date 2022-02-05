AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

SpectrumClass = AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5

class AR.Pages.Optics.Sky extends AR.Pages.Optics.Sky
  computeScratchapixelRGB: ->
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
    scatteringCoefficientRayleigh = new THREE.Vector3().copy(rayleighCrossSection).multiplyScalar(molecularNumberDensitySurface)

    # This was the value used in the article.
    # scatteringCoefficientRayleigh = new THREE.Vector3 3.8e-6, 13.5e-6, 33.1e-6

    scatteringCoefficientMie = new THREE.Vector3 21e-6, 21e-6, 21e-6

    phaseFunctionRayleigh = AR.Optics.Scattering.getRayleighPhaseFunction()
    phaseFunctionMie = AR.Optics.Scattering.getMiePhaseFunctionForAsymmetry 0.76

    scaleHeightRayleigh = 7994
    scaleHeightMie = 1200

    emissionSpectrum = new AR.Optics.Spectrum.RGB().copy(@sunEmissionSpectrum).toVector3()

    # Prepare color calculation method.
    totalRadiance = new THREE.Vector3()

    origin = new THREE.Vector3()
    samplePosition = new THREE.Vector3()
    samplePositionLight = new THREE.Vector3()

    sunAngleDegrees = @sunAngleDegrees()
    sunAngle = AR.Degrees Math.round sunAngleDegrees
    sunDirection = new THREE.Vector3 Math.sin(sunAngle), Math.cos(sunAngle), 0

    sumRayleigh = new THREE.Vector3()
    sumMie = new THREE.Vector3()

    tau = new THREE.Vector3()
    tauRayleigh = new THREE.Vector3()
    tauMie = new THREE.Vector3()

    attenuation = new THREE.Vector3()
    attenuationRayleigh = new THREE.Vector3()
    attenuationMie = new THREE.Vector3()

    @_computePreviewData (height, direction) =>
      # Set origin parameters.
      origin.set 0, @earthRadius + height, 0
      sunViewAngle = sunDirection.angleTo direction

      if @_intersectsEarth origin, direction
        tMax = @_getLengthToEarth origin, direction

      else
        tMax = @_getLengthThroughAtmosphere origin, direction

      numSamples = 16
      numSamplesLight = 8

      segmentLength = tMax / numSamples

      tCurrent = 0

      sumRayleigh.set 0, 0, 0
      sumMie.set 0, 0, 0

      opticalDepthRayleigh = 0
      opticalDepthMie = 0

      phaseRayleigh = phaseFunctionRayleigh sunViewAngle
      phaseMie = phaseFunctionMie sunViewAngle

      for i in [0...numSamples]
        samplePosition.copy(direction).multiplyScalar(tCurrent + segmentLength * 0.5).add(origin)
        height = samplePosition.length() - @earthRadius

        # Compute optical depth for light.
        densityFactorRayleigh = Math.E ** (-height / scaleHeightRayleigh) * segmentLength
        densityFactorMie = Math.E ** (-height / scaleHeightMie) * segmentLength

        opticalDepthRayleigh += densityFactorRayleigh
        opticalDepthMie += densityFactorMie

        if rayleighScatteringEnabled or mieScatteringEnabled
          # Light optical depth.
          sunRayLength = @_getLengthThroughAtmosphere samplePosition, sunDirection
          segmentLengthLight = sunRayLength / numSamplesLight
          tCurrentLight = 0

          opticalDepthLightRayleigh = 0
          opticalDepthLightMie = 0

          intersected = false

          for j in [0...numSamplesLight]
            samplePositionLight.copy(sunDirection).multiplyScalar(tCurrentLight + segmentLengthLight * 0.5).add(samplePosition)
            heightLight = samplePositionLight.length() - @earthRadius

            if heightLight < 0
              intersected = true
              break

            opticalDepthLightRayleigh += Math.E ** (-heightLight / scaleHeightRayleigh) * segmentLengthLight
            opticalDepthLightMie += Math.E ** (-heightLight / scaleHeightMie) * segmentLengthLight

            tCurrentLight += segmentLengthLight

          unless intersected
            tau.set(0, 0, 0)

            if rayleighScatteringEnabled
              tauRayleigh.copy(scatteringCoefficientRayleigh).multiplyScalar(opticalDepthRayleigh + opticalDepthLightRayleigh)
              tau.add(tauRayleigh)

            if mieScatteringEnabled
              tauMie.copy(scatteringCoefficientMie).multiplyScalar(opticalDepthMie + opticalDepthLightMie)
              tau.add(tauMie)

            attenuation.copy(tau).negate().exp()

            if rayleighScatteringEnabled
              attenuationRayleigh.copy(attenuation).multiplyScalar(densityFactorRayleigh)
              sumRayleigh.add(attenuationRayleigh)

            if mieScatteringEnabled
              attenuationMie.copy(attenuation).multiplyScalar(densityFactorMie)
              sumMie.add(attenuationMie)

        tCurrent += segmentLength

      sumRayleigh.multiply(scatteringCoefficientRayleigh).multiplyScalar(phaseRayleigh)
      sumMie.multiply(scatteringCoefficientMie).multiplyScalar(phaseMie)

      totalRadiance.set(0, 0, 0)
      totalRadiance.add(sumRayleigh) if rayleighScatteringEnabled
      totalRadiance.add(sumMie) if mieScatteringEnabled

      # Include direct sun.
      if directLightEnabled and Math.abs(sunViewAngle) < AR.Degrees(0.53) and not @_intersectsEarth(origin, direction)
        tauRayleigh.copy(scatteringCoefficientRayleigh).multiplyScalar(opticalDepthRayleigh)
        tauMie.copy(scatteringCoefficientMie).multiplyScalar(opticalDepthMie)
        tau.copy(tauRayleigh).add(tauMie)

        attenuation.copy(tau).negate().exp()
        totalRadiance.add(attenuation)

      totalRadiance.multiply(emissionSpectrum)

      Artificial.Spectrum.Color.SRGB.getXYZForRGB
        r: totalRadiance.x
        g: totalRadiance.y
        b: totalRadiance.z
