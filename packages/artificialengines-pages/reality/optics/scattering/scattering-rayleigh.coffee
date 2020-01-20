AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality
AP = Artificial.Pyramid

class AR.Pages.Optics.Scattering extends AR.Pages.Optics.Scattering
  @register 'Artificial.Reality.Pages.Optics.Scattering'

  drawRayleighScattering: ->
    canvas = @$('.preview')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    offsetLeft = 10
    offsetTop = 10
    context.translate offsetLeft + 0.5, offsetTop + 0.5

    preview =
      width: 200
      height: 151
      scale: 2000 # 1px = 1km

    volume =
      left: 50
      top: 50
      width: 100
      height: 51

    volume.right = volume.left + volume.width - 1
    volume.bottom = volume.top + volume.height - 1

    # Prepare radiance transfer data structure.
    radianceData =
      width: preview.width
      height: Math.ceil preview.height / 2
      cells: []

    radianceData.volumeBottom = Math.ceil volume.height / 2

    SpectrumClass = AR.Optics.Spectrum.UniformlySampled.Range380To780Spacing5

    for x in [0...radianceData.width]
      radianceData.cells[x] = []

      for y in [0...radianceData.height]
        radianceData.cells[x][y] =
          inTotal: new SpectrumClass
          out: []
          neighbors: []

        for directionIndex in [0..3]
          radianceData.cells[x][y].out[directionIndex] = new SpectrumClass

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

    for x in [0...radianceData.width]
      for y in [0...radianceData.height]
        neighbors = radianceData.cells[x][y].neighbors

        for neighborDelta, index in neighborDeltas
          nx = x + neighborDelta.x
          ny = y + neighborDelta.y
          continue unless 0 <= nx < radianceData.width and 0 <= ny < radianceData.height

          neighbors[index] = radianceData.cells[nx][ny]

    # Connect source cell.
    D65EmissionSpectrum = AR.Optics.LightSources.CIE.D65.getEmissionSpectrum()

    sourceCell =
      out: [null, D65EmissionSpectrum]

    radianceData.cells[0][0].neighbors[3] = sourceCell

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

    rayleighCoefficientSpectrum = new SpectrumClass
    rayleighCoefficientSpectrum.copy new AR.Optics.Spectrum.Formulated (wavelength) =>
      refractiveIndex = refractiveIndexSpectrum.getValue wavelength
      kingCorrectionFactor = kingCorrectionFactorSpectrum?.getValue wavelength

      rayleighCoefficientFunction refractiveIndex, molecularNumberDensity, wavelength, kingCorrectionFactor

    scatteredRatioSpectrum = new SpectrumClass
    transferredRatioSpectrum = new SpectrumClass
    scatteredSpectrum = new SpectrumClass
    transferredSpectrum = new SpectrumClass
    scatteredSpectrumToDirection = new SpectrumClass

    cellDistance = preview.scale

    # Precalculate direction intensities for 4 sides.
    rayleighPhaseFunction = AR.Optics.Scattering.getRayleighPhaseFunction()
    directionIntensities = []

    for offsetDirectionIndex in [0..3]
      startDegrees = -45 + 90 * offsetDirectionIndex
      endDegrees = startDegrees + 90

      intensity = 0

      for degrees in [startDegrees + 0.5..endDegrees - 0.5] by 1
        radians = degrees * Math.PI / 180
        intensity += rayleighPhaseFunction radians

      directionIntensities[offsetDirectionIndex] = intensity

    totalDirectionIntensity = _.sum directionIntensities

    for offsetDirectionIndex in [0..3]
      directionIntensities[offsetDirectionIndex] /= totalDirectionIntensity

    # Propagate radiation.
    for iteration in [1..4]
      minX = 0
      maxX = radianceData.width - 1
      dx = 1

      minY = 0
      maxY = radianceData.height - 1
      dy = 1

      if iteration % 2 is 0
        [minX, maxX] = [maxX, minX]
        dx = -1

      if Math.ceil(iteration / 2) % 2 is 0
        [minY, maxY] = [maxY, minY]
        dy = -1

      for x in [minX..maxX] by dx
        for y in [minY..maxY] by dy
          cell = radianceData.cells[x][y]

          # Clear previously computed radiance.
          cell.inTotal.clear()

          for directionIndex in [0..3]
            cell.out[directionIndex].clear()

          # Transfer the incoming radiance from all four sides.
          for neighborIndex in [0..3]
            # We need to read the out spectrum in the direction opposite of the neighbor (pointing towards this cell).
            directionIndex = (neighborIndex + 2) % 4

            continue unless neighborOutRadiance = radianceData.cells[x][y].neighbors[neighborIndex]?.out[directionIndex]

            cell.inTotal.add neighborOutRadiance

            # See if we're inside the gas volume.
            if volume.left <= x <= volume.right and y < radianceData.volumeBottom
              # Calculate how much of the light gets transferred and how much scattered.
              #            -βl
              # Lt = Lo * e
              transferredRatioSpectrum.copy(rayleighCoefficientSpectrum).negate().multiplyScalar(cellDistance).exp()
              scatteredRatioSpectrum.setConstant(1).subtract(transferredRatioSpectrum)

              # Scatter the incoming radiance to all eight directions based on the rayleigh phase function.
              scatteredSpectrum.copy(neighborOutRadiance).multiply(scatteredRatioSpectrum)

              for offsetDirectionIndex in [0..3]
                scatteredSpectrumToDirection.copy(scatteredSpectrum).multiplyScalar(directionIntensities[offsetDirectionIndex])
                scatteredDirectionIndex = (directionIndex + offsetDirectionIndex) % 4
                cell.out[scatteredDirectionIndex].add(scatteredSpectrumToDirection)

            else
              # We're in the vacuum and no scattering is occuring.
              transferredRatioSpectrum.setConstant(1)

            # Transfer the unscattered portion to the incoming ray direction.
            transferredSpectrum.copy(neighborOutRadiance).multiply(transferredRatioSpectrum)
            cell.out[directionIndex].add(transferredSpectrum)

    # Clear preview to black.
    context.fillStyle = 'black'
    context.fillRect 0, 0, preview.width, preview.height

    # Draw radiance data.
    previewImageData = context.getImageData offsetLeft, offsetTop, preview.width, preview.height
    middleYIndex = radianceData.height

    exposure = 2

    for x in [0...radianceData.width]
      for ry in [0...radianceData.height]
        xyz = AS.Color.CIE1931.getXYZForSpectrum radianceData.cells[x][ry].inTotal
        xyz.x *= exposure
        xyz.y *= exposure
        xyz.z *= exposure
        rgb = AS.Color.SRGB.getRGBForXYZ xyz

        for y in [middleYIndex - ry, middleYIndex + ry]
          pixelOffset = (x + y * previewImageData.width) * 4

          previewImageData.data[pixelOffset] = rgb.r * 255
          previewImageData.data[pixelOffset + 1] = rgb.g * 255
          previewImageData.data[pixelOffset + 2] = rgb.b * 255

    context.putImageData previewImageData, offsetLeft, offsetTop

    # Draw the volume.
    context.strokeStyle = 'gainsboro'
    context.lineWidth = 1
    context.globalAlpha = 0.2
    context.strokeRect volume.left - 1, volume.top - 1, volume.width + 1, volume.height + 1
    context.globalAlpha = 1

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 0, 0, preview.width, preview.height

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "distance (km)", 90, 190

    context.beginPath()

    for x in [0..preview.width] by 50
      # Write the number on the axis.
      xKilometers = Math.round x * preview.scale / 1e3

      context.textAlign = 'center'
      context.fillText xKilometers, x, preview.height + 16
