AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AR.Pages.Chemistry.Gases extends AR.Pages.Chemistry.Gases
  @register 'Artificial.Reality.Pages.Chemistry.Gases'

  drawSpectrumGraph: ->
    canvas = @$('.spectrum-graph')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    # Prepare coordinate system.
    context.translate 70 + 0.5, 10 + 0.5

    graphWidth = 400
    graphHeight = 250

    yAxisProperty = @spectrumYAxisProperty()

    xAxisScale =
      min: 380e-9
      max: 780e-9
      multiplier: 1e-9
      name: 'Wavelength'
      unit: 'nm'

    yAxisScale = @constructor.Scales[yAxisProperty]

    getCanvasX = (x) => (x - xAxisScale.min) / (xAxisScale.max - xAxisScale.min) * graphWidth
    getCanvasY = (y) => graphHeight - (y - (yAxisScale.subtract or 0)) / yAxisScale.range * graphHeight

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "#{xAxisScale.name} (#{xAxisScale.unit})", graphWidth / 2, graphHeight + 40

    context.save()
    context.setTransform 1, 0, 0, 1, 0, 0
    context.rotate -Math.PI / 2
    context.fillText "#{yAxisScale.name} (#{yAxisScale.unit})", -(graphHeight / 2) - 10, 30
    context.restore()

    context.beginPath()

    formatAxisNumber = (number) ->
      if Math.round(number * 10) % 10
        number.toFixed 1

      else
        number.toFixed 0

    for x in [4..7.5] by 0.5
      offset = getCanvasX x * 100e-9

      # Draw a vertical line.
      context.moveTo offset, 0
      context.lineTo offset, graphHeight

      # Write the number on the x axis.
      context.textAlign = 'center'
      xNumber = x * 100
      context.fillText xNumber, offset, graphHeight + 16

    verticalSections = 5

    for y in [0..verticalSections]
      offset = y / verticalSections * graphHeight

      # Draw a horizontal line.
      context.moveTo 0, offset
      context.lineTo graphWidth, offset

      # Write the number on the y axis.
      context.textAlign = 'right'
      yNumber = (verticalSections - y) / verticalSections / (yAxisScale.multiplier or 1) * yAxisScale.range
      context.fillText formatAxisNumber(yNumber), -8, offset + 4

    context.strokeStyle = 'lightslategrey'
    context.stroke()

    # Clip drawing to the graph area.
    context.save()
    context.beginPath()
    context.rect 0, 0, graphWidth, graphHeight
    context.clip()

    # Draw spectrum value.
    gasClass = @gasClass()
    gasState = @getGasState()
    refractiveIndexSpectrum = gasClass.getRefractiveIndexSpectrumForState gasState
    kingCorrectionFactorSpectrum = gasClass.getKingCorrectionFactorSpectrum()

    switch yAxisProperty
      when @constructor.SpectrumProperties.RefractiveIndex
        spectrum = refractiveIndexSpectrum

      when @constructor.SpectrumProperties.KingCorrectionFactor
        spectrum = kingCorrectionFactorSpectrum

      when @constructor.SpectrumProperties.RayleighScatteringCrossSection
        rayleighCrossSectionFunction = AR.Optics.Scattering.getRayleighCrossSectionFunction()

        spectrum = (wavelength) ->
          refractiveIndex = refractiveIndexSpectrum wavelength
          kingCorrectionFactor = kingCorrectionFactorSpectrum? wavelength

          rayleighCrossSectionFunction refractiveIndex, gasState.amountOfSubstance / gasState.volume * AR.AvogadroNumber, wavelength, kingCorrectionFactor

    if spectrum
      for x in [0...graphWidth]
        wavelength = xAxisScale.min + x / graphWidth * (xAxisScale.max - xAxisScale.min)
        context.lineTo x, getCanvasY spectrum(wavelength) or 0

      context.strokeStyle = 'ghostwhite'
      context.stroke()

    # Draw current wavelength.
    wavelength = @wavelength()
    x = getCanvasX wavelength

    context.beginPath()
    context.moveTo x, 0
    context.lineTo x, graphHeight

    context.globalAlpha = 0.2
    context.lineWidth = 1
    context.strokeStyle = 'ghostwhite'
    context.stroke()
    context.globalAlpha = 1

    # Draw measurement points on graph.
    context.fillStyle = "white"

    measurementProperty = @constructor.SpectrumPropertyFieldNames[yAxisProperty]

    if measurements = @constructor.Measurements[gasClass.id()]
      for measurement in measurements when measurement[measurementProperty]
        x = getCanvasX measurement.wavelength
        y = getCanvasY measurement[measurementProperty]

        @_drawPoint context, x, y, 4

    # Restore to no clipping.
    context.restore()

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 0, 0, graphWidth, graphHeight
