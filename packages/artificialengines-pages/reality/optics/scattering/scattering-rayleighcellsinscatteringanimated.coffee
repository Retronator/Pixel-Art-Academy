AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Scattering extends AR.Pages.Optics.Scattering
  prepareRayleighScatteringCellsInscatteringAnimated: ->
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
          x: x
          y: y

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
    @rayleighPhaseFunction = AR.Optics.Scattering.getRayleighPhaseFunction()
    @directionAngles = [0, Math.PI / 2, Math.PI, 3 * Math.PI / 2]

    @time = 0

    @scatteredRatioSpectrum = new @SpectrumClass
    @transferredRatioSpectrum = new @SpectrumClass
    @inscatteredSpectrum = new @SpectrumClass
    @transferredSpectrum = new @SpectrumClass

  drawRayleighScatteringCellsInscatteringAnimated: ->
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
          continue unless neighbor = @radianceData.cells[x][y].neighbors[neighborIndex]

          # We need to read the out spectrum in the direction opposite of the neighbor (pointing towards this cell).
          directionIndex = (neighborIndex + 2) % 4
          neighborOutRadiance = neighbor.out[directionIndex]

          # See if neighbor is inside the gas volume.
          if @volume.left <= neighbor.x <= @volume.right and neighbor.y < @radianceData.volumeBottom
            # Calculate how much of the light gets transferred and how much scattered.
            #            -βl
            # Lt = Lo * e
            @transferredRatioSpectrum.copy(@rayleighCoefficientSpectrum).negate().multiplyScalar(cellDistance).exp()

            # Calculate inscattering.
            for offsetDirectionIndex in [0..3]
              scatteringSourceDirectionIndex = (directionIndex + offsetDirectionIndex) % 4
              @inscatteredSpectrum.copy(neighbor.out[scatteringSourceDirectionIndex]).multiply(@rayleighCoefficientSpectrum).multiplyScalar(@rayleighPhaseFunction(@directionAngles[offsetDirectionIndex]) * cellDistance)
              cell.outNext[directionIndex].add(@inscatteredSpectrum)

          else
            # We're in the vacuum and no scattering is occurring.
            @transferredRatioSpectrum.setConstant(1)

          # Transfer the unscattered portion to the incoming ray direction.
          @transferredSpectrum.copy(neighborOutRadiance).multiply(@transferredRatioSpectrum)
          cell.outNext[directionIndex].add(@transferredSpectrum)

          cell.inTotal.add cell.outNext[directionIndex]

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
        rgb = AS.Color.SRGB.getGammaRGBForXYZ xyz

        for y in [middleYIndex - ry, middleYIndex + ry]
          pixelOffset = (x + y * @previewImageData.width) * 4

          @previewImageData.data[pixelOffset] = rgb.r * 255
          @previewImageData.data[pixelOffset + 1] = rgb.g * 255
          @previewImageData.data[pixelOffset + 2] = rgb.b * 255

    @context.putImageData @previewImageData, @offsetLeft, @offsetTop

    @_drawPreviewElements()

    @time++
