AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Scattering extends AR.Pages.Optics.Scattering
  drawRayleighScatteringSingle: ->
    # Prepare data.
    materialClass = @materialClass()

    gasState =
      temperature: AR.StandardTemperatureAndPressure.Temperature
      pressure: AR.StandardTemperatureAndPressure.Pressure * @densityFactor()
      volume: 1

    amountOfSubstance = materialClass.getAmountOfSubstanceForState gasState
    molarConcentration = amountOfSubstance / gasState.volume
    molecularNumberDensity = molarConcentration * AR.AvogadroNumber

    refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrumForState gasState
    kingCorrectionFactorSpectrum = materialClass.getKingCorrectionFactorSpectrum()
    rayleighCoefficientFunction = AR.Optics.Scattering.getRayleighCoefficientFunction()

    rayleighCoefficientSpectrum = new @SpectrumClass
    rayleighCoefficientSpectrum.copy new AR.Optics.Spectrum.Formulated (wavelength) =>
      refractiveIndex = refractiveIndexSpectrum.getValue wavelength
      kingCorrectionFactor = kingCorrectionFactorSpectrum?.getValue wavelength

      rayleighCoefficientFunction refractiveIndex, molecularNumberDensity, wavelength, kingCorrectionFactor

    rayleighPhaseFunction = AR.Optics.Scattering.getRayleighPhaseFunction()

    @_startDraw()

    # Draw radiance data.
    previewImageData = @context.getImageData @offsetLeft, @offsetTop, @preview.width, @preview.height
    middleYIndex = Math.floor @preview.height / 2

    radiance = new @SpectrumClass
    totalRadiance = new @SpectrumClass

    vectorCD = new THREE.Vector2
    vectorCDDown = new THREE.Vector2

    positionC = new THREE.Vector3
    positionP = new THREE.Vector3
    positionD = new THREE.Vector3
    rayDirection = new THREE.Vector3
    rayCP = new THREE.Ray positionC, rayDirection

    volumeBottomFromRay = @volume.height / 2
    planeDown = new THREE.Plane new THREE.Vector3(0, 1, 0), -volumeBottomFromRay
    planeLeft = new THREE.Plane new THREE.Vector3(-1, 0, 0), 0
    planeRight = new THREE.Plane new THREE.Vector3(1, 0, 0), -@volume.width

    exposure = 5

    for x in [0...@preview.width]
      rx = x - @volume.left
      positionP.x = rx

      for ry in [0..middleYIndex]
        positionP.y = ry
        totalRadiance.clear()

        # Integrate scattered light contribution along the ray inside the @volume.
        for c in [0...@volume.width]
          positionC.x = c
          distanceAC = c
          rayDirection.subVectors(positionP, positionC).normalize()

          if (rx is c)
            θ = Math.PI / 2

          else
            θ = Math.atan(ry / (rx - c))

          if 0 <= rx < @volume.width
            if ry < volumeBottomFromRay
              # We're in the @volume.
              vectorCD.set rx - c, ry

            else
              # We're below the @volume.
              rayCP.intersectPlane planeDown, positionD
              vectorCD.set positionD.x - c, positionD.y

          else
            if rx < 0
              # We're left of the @volume.
              rayCP.intersectPlane planeLeft, positionD
              vectorCD.set positionD.x - c, positionD.y

            else
              # We're right of the @volume.
              rayCP.intersectPlane planeRight, positionD
              vectorCD.set positionD.x - c, positionD.y

            if ry >= volumeBottomFromRay
              # We're also below the @volume. See if we might be closer to the bottom edge.
              rayCP.intersectPlane planeDown, positionD
              vectorCDDown.set positionD.x - c, positionD.y

              vectorCD.copy vectorCDDown if vectorCDDown.length() < vectorCD.length()

          distanceCD = vectorCD.length()
          travelDistance = (distanceAC + distanceCD) * @preview.scale

          radiance.copy(rayleighCoefficientSpectrum).negate().multiplyScalar(travelDistance).exp().multiplyScalar(rayleighPhaseFunction(θ))
          totalRadiance.add radiance

        totalRadiance.multiply(rayleighCoefficientSpectrum).multiply(@D65EmissionSpectrum).multiplyScalar(@preview.scale)

        unless ry
          # We're in the ray row, so also add transmitted ray light up to that point.
          distanceRay = _.clamp(rx, 0, @volume.width) * @preview.scale
          radiance.copy(rayleighCoefficientSpectrum).negate().multiplyScalar(distanceRay).exp().multiply(@D65EmissionSpectrum)

          totalRadiance.add radiance

        xyz = AS.Color.XYZ.getXYZForSpectrum totalRadiance

        xyz.x *= exposure
        xyz.y *= exposure
        xyz.z *= exposure
        rgb = AS.Color.SRGB.getGammaRGBForXYZ xyz

        for y in [middleYIndex - ry, middleYIndex + ry]
          pixelOffset = (x + y * previewImageData.width) * 4

          previewImageData.data[pixelOffset] = rgb.r * 255
          previewImageData.data[pixelOffset + 1] = rgb.g * 255
          previewImageData.data[pixelOffset + 2] = rgb.b * 255

    @context.putImageData previewImageData, @offsetLeft, @offsetTop

    @_drawPreviewElements()
