AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Scattering extends AR.Pages.Optics.Scattering
  @register 'Artificial.Reality.Pages.Optics.Scattering'

  prepareRayleighScatteringSingleAnimated: ->
    # Prepare radiance transfer data structure.
    @radianceData =
      width: @preview.width
      height: Math.ceil @preview.height / 2
      cells: []

    @radianceData.volumeBottom = Math.ceil @volume.height / 2

    for x in [0...@radianceData.width]
      @radianceData.cells[x] = []

      for y in [0...@radianceData.height]
        @radianceData.cells[x][y] =
          scattering: []

        for c in [0...@volume.width]
          @radianceData.cells[x][y].scattering[c] =
            travelDistance: null
            angle: null
            radiance: new @SpectrumClass

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

    @rayleighCoefficientSpectrum = new @SpectrumClass
    @rayleighCoefficientSpectrum.copy new AR.Optics.Spectrum.Formulated (wavelength) =>
      refractiveIndex = refractiveIndexSpectrum.getValue wavelength
      kingCorrectionFactor = kingCorrectionFactorSpectrum?.getValue wavelength

      rayleighCoefficientFunction refractiveIndex, molecularNumberDensity, wavelength, kingCorrectionFactor

    rayleighPhaseFunction = AR.Optics.Scattering.getRayleighPhaseFunction()

    vectorCD = new THREE.Vector2
    vectorCDDown = new THREE.Vector2

    positionC = new THREE.Vector3
    positionP = new THREE.Vector3
    positionD = new THREE.Vector3
    rayDirection = new THREE.Vector3
    rayDistance = new THREE.Vector3
    rayCP = new THREE.Ray positionC, rayDirection

    volumeBottomFromRay = @volume.height / 2
    planeDown = new THREE.Plane new THREE.Vector3(0, 1, 0), -volumeBottomFromRay
    planeLeft = new THREE.Plane new THREE.Vector3(-1, 0, 0), 0
    planeRight = new THREE.Plane new THREE.Vector3(1, 0, 0), -@volume.width

    @scatteringConstantFactorSpectrum = new @SpectrumClass().copy(@rayleighCoefficientSpectrum).multiply(@D65EmissionSpectrum).multiplyScalar(@preview.scale)

    for x in [0...@radianceData.width]
      rx = x - @volume.left
      positionP.x = rx

      for ry in [0...@radianceData.height]
        positionP.y = ry

        # Calculate scattered light contribution along the ray inside the volume.
        for c in [0...@volume.width]
          positionC.x = c
          distanceAC = c
          rayDistance.subVectors(positionP, positionC)
          rayDirection.copy(rayDistance).normalize()

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

          scattering = @radianceData.cells[x][ry].scattering[c]
          scattering.angle = θ
          scattering.travelDistance = (@volume.left + c + rayDistance.length()) * @preview.scale
          scattering.radiance.copy(@rayleighCoefficientSpectrum).negate().multiplyScalar(travelDistance).exp().multiplyScalar(rayleighPhaseFunction(θ)).multiply(@scatteringConstantFactorSpectrum)

    @time = 0

  drawRayleighScatteringSingleAnimated: ->
    @_startDraw()

    # Draw radiance data.
    @previewImageData = @context.getImageData @offsetLeft, @offsetTop, @preview.width, @preview.height
    middleYIndex = @radianceData.height

    exposure = 5

    minTravelDistance = (@time - 4) * @preview.scale * 0.5
    maxTravelDistance = @time * @preview.scale * 0.5

    totalRadiance = new @SpectrumClass
    radiance = new @SpectrumClass

    for x in [0...@radianceData.width]
      rx = x - @volume.left

      for ry in [0...@radianceData.height]
        totalRadiance.clear()

        for c in [0...@volume.width]
          scattering = @radianceData.cells[x][ry].scattering[c]
          continue unless minTravelDistance <= scattering.travelDistance <= maxTravelDistance

          totalRadiance.add scattering.radiance

        unless ry
          # We're in the ray row, so also add transmitted ray light up to that point.
          distance = x * @preview.scale
          distanceVolume = _.clamp(rx, 0, @volume.width) * @preview.scale

          if minTravelDistance <= distance <= maxTravelDistance
            radiance.copy(@rayleighCoefficientSpectrum).negate().multiplyScalar(distanceVolume).exp().multiply(@D65EmissionSpectrum)

            totalRadiance.add radiance

        xyz = AS.Color.CIE1931.getXYZForSpectrum totalRadiance
        xyz.x *= exposure
        xyz.y *= exposure
        xyz.z *= exposure
        rgb = AS.Color.SRGB.getRGBForXYZ xyz

        for y in [middleYIndex - ry, middleYIndex + ry]
          pixelOffset = (x + y * @previewImageData.width) * 4

          @previewImageData.data[pixelOffset] = rgb.r * 255
          @previewImageData.data[pixelOffset + 1] = rgb.g * 255
          @previewImageData.data[pixelOffset + 2] = rgb.b * 255

    @context.putImageData @previewImageData, @offsetLeft, @offsetTop

    @_drawPreviewElements()

    @time++
