AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Scattering extends AR.Pages.Optics.Scattering
  prepareRayleighScatteringCellsAnimated: ->
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
          inTotal: new @SpectrumClass
          out: []
          outNext: []
          neighbors: []

        for directionIndex in [0..3]
          @radianceData.cells[x][y].out[directionIndex] = new @SpectrumClass
          @radianceData.cells[x][y].outNext[directionIndex] = new @SpectrumClass

    # Connect neighbors.
    neighborDeltas = [
      x: 0, y: -1 # Up
    ,
      x: 1, y: 0 # Right
    ,
      x: 0, y: 1 # Down
    ,
      x: -1, y: 0 # Left
    ]

    for x in [0...@radianceData.width]
      for y in [0...@radianceData.height]
        neighbors = @radianceData.cells[x][y].neighbors

        for neighborDelta, index in neighborDeltas
          nx = x + neighborDelta.x
          ny = y + neighborDelta.y
          continue unless 0 <= nx < @radianceData.width and 0 <= ny < @radianceData.height

          neighbors[index] = @radianceData.cells[nx][ny]

    # Connect source cell.
    D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

    @sourceCell =
      out: [null, D65EmissionSpectrum]

    @radianceData.cells[0][0].neighbors[3] = @sourceCell

    # Prepare spectrums.
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

    # Precalculate direction intensities for 4 sides.
    rayleighPhaseFunction = AR.Optics.Scattering.getRayleighPhaseFunction()
    @directionIntensities = []

    for offsetDirectionIndex in [0..3]
      startDegrees = -45 + 90 * offsetDirectionIndex

      startRadians = startDegrees * Math.PI / 180
      endRadians = startRadians + Math.PI / 2

      @directionIntensities[offsetDirectionIndex] = AP.Integration.integrateWithMidpointRule rayleighPhaseFunction, startRadians, endRadians, Math.PI / 180

    @time = 0

  drawRayleighScatteringCellsAnimated: ->
    scatteredRatioSpectrum = new @SpectrumClass
    transferredRatioSpectrum = new @SpectrumClass
    scatteredSpectrum = new @SpectrumClass
    transferredSpectrum = new @SpectrumClass
    scatteredSpectrumToDirection = new @SpectrumClass

    cellDistance = @preview.scale

    #@sourceCell.out[1] = null if @time > 3

    # Transfer new out radiance to current.
    for x in [0...@radianceData.width]
      for y in [0...@radianceData.height]
        cell = @radianceData.cells[x][y]
        [cell.out, cell.outNext] = [cell.outNext, cell.out]

    # Propagate radiation.
    for x in [0...@radianceData.width]
      for y in [0...@radianceData.height]
        cell = @radianceData.cells[x][y]

        # Clear previously computed radiance.
        cell.inTotal.clear()

        for directionIndex in [0..3]
          cell.outNext[directionIndex].clear()

        # Transfer the incoming radiance from all four sides.
        for neighborIndex in [0..3]
          # We need to read the out spectrum in the direction opposite of the neighbor (pointing towards this cell).
          directionIndex = (neighborIndex + 2) % 4

          continue unless neighborOutRadiance = @radianceData.cells[x][y].neighbors[neighborIndex]?.out[directionIndex]

          cell.inTotal.add neighborOutRadiance

          # See if we're inside the gas @volume.
          if @volume.left <= x <= @volume.right and y < @radianceData.volumeBottom
            # Calculate how much of the light gets transferred and how much scattered.
            #            -βl
            # Lt = Lo * e
            transferredRatioSpectrum.copy(@rayleighCoefficientSpectrum).negate().multiplyScalar(cellDistance).exp()
            scatteredRatioSpectrum.setConstant(1).subtract(transferredRatioSpectrum)

            # Scatter the incoming radiance to all four directions based on the rayleigh phase function.
            scatteredSpectrum.copy(neighborOutRadiance).multiply(scatteredRatioSpectrum)

            for offsetDirectionIndex in [0..3]
              scatteredSpectrumToDirection.copy(scatteredSpectrum).multiplyScalar(@directionIntensities[offsetDirectionIndex])
              scatteredDirectionIndex = (directionIndex + offsetDirectionIndex) % 4
              cell.outNext[scatteredDirectionIndex].add(scatteredSpectrumToDirection)

          else
            # We're in the vacuum and no scattering is occuring.
            transferredRatioSpectrum.setConstant(1)

          # Transfer the unscattered portion to the incoming ray direction.
          transferredSpectrum.copy(neighborOutRadiance).multiply(transferredRatioSpectrum)
          cell.outNext[directionIndex].add(transferredSpectrum)

    @_startDraw()

    # Draw radiance data.
    @previewImageData = @context.getImageData @offsetLeft, @offsetTop, @preview.width, @preview.height
    middleYIndex = @radianceData.height

    exposure = 5

    for x in [0...@radianceData.width]
      for ry in [0...@radianceData.height]
        xyz = AS.Color.CIE1931.getXYZForSpectrum @radianceData.cells[x][ry].inTotal
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
