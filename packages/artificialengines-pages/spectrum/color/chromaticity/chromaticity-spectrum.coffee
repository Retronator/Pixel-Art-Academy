AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AS.Pages.Color.Chromaticity extends AS.Pages.Color.Chromaticity
  drawSpectrum: ->
    canvas = @$('.spectrum')[0]
    context = canvas.getContext '2d'
    context.setTransform 1, 0, 0, 1, 0, 0

    # Color the canvas the same as the background. We do not want
    # transparent color so that we can do blending operations over it.
    context.fillStyle = 'slategray'
    context.fillRect 0, 0, canvas.width, canvas.height

    # Prepare coordinate system.
    context.translate -380 + 50 + 0.5, 10 + 0.5
    context.lineWidth = 1

    yAxis = @spectrumYAxis()

    getCanvasY = (y) => (yAxis.maxValue - y) * (400 / yAxis.maxValue)
    getCanvasYinSI = (si) => getCanvasY si / 1e12

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "λ (nm)", 580, 440

    context.save()
    context.setTransform 1, 0, 0, 1, 0, 0
    context.rotate -Math.PI / 2
    context.fillText "Spectral radiance Le,Ω,λ (kW / sr·m²·nm)", -210, 20
    context.restore()

    context.beginPath()

    for wavelengthNanometers in [400..750] by 50
      # Draw a vertical line.
      context.moveTo wavelengthNanometers, 0
      context.lineTo wavelengthNanometers, 400

      # Write the number on the axis.
      context.textAlign = 'center'
      context.fillText wavelengthNanometers, wavelengthNanometers, 416

    context.strokeStyle = 'lightslategray'
    context.stroke()

    for y in [0..yAxis.maxValue] by yAxis.spacing
      canvasY = getCanvasY y

      # Draw a horizontal line.
      context.moveTo 380, canvasY
      context.lineTo 780, canvasY

      # Write the number on the axis.
      context.textAlign = 'right'

      if Math.round(y) is y
        number = y

      else
        number = y.toFixed 1

      context.fillText number, 372, canvasY + 4

    context.stroke()

    # Clip drawing to the graph area.
    context.save()
    context.beginPath()
    context.rect 380, 0, 400, 400
    context.clip()

    # Draw correlated color temperature.
    if correlatedColorTemperature = @correlatedColorTemperature()
      blackBodyEmissionSpectrum = AR.Optics.LightSources.BlackBody.getEmissionSpectrumForTemperature correlatedColorTemperature

      context.beginPath()

      for wavelengthNanometers in [380..780]
        wavelength = wavelengthNanometers / 1e9
        spectralRadiance = blackBodyEmissionSpectrum.getValue wavelength
        y = getCanvasYinSI spectralRadiance
        context.lineTo wavelengthNanometers, y

      context.setLineDash [3, 3]
      context.strokeStyle = 'gainsboro'
      context.stroke()
      context.setLineDash []

    # Draw light source spectrum.
    if lightSourceEmissionSpectrum = @lightSourceEmissionSpectrum()
      # Draw radiation color with screen blending mode.
      context.globalCompositeOperation = 'screen'

      context.beginPath()

      for wavelengthNanometers in [380..780]
        wavelength = wavelengthNanometers / 1e9
        spectralRadiance = lightSourceEmissionSpectrum.getValue wavelength
        y = getCanvasYinSI spectralRadiance

        # Draw histogram top line.
        context.lineTo wavelengthNanometers, y

        # Color area under histogram with wavelength color.
        rgb = AS.Color.SRGB.getGammaRGBForNormalizedRGB AS.Color.SRGB.getRGBForXYZ AS.Color.XYZ.getRelativeXYZForWavelength wavelength
        context.fillStyle = "rgba(#{rgb.r * 255}, #{rgb.g * 255}, #{rgb.b * 255}, 0.5)"

        height = getCanvasY(0) - y
        context.fillRect wavelengthNanometers - 0.5, y, 1, height

      context.globalCompositeOperation = 'source-over'

      context.strokeStyle = 'gainsboro'
      context.stroke()

    # Draw color matching functions.
    colors =
      x: 'red'
      y: 'lime'
      z: 'blue'

    for matchingFunctionLetter in ['x', 'y', 'z']
      matchingFunction = AS.Color.XYZ.ColorMatchingFunctions[matchingFunctionLetter]

      context.beginPath()

      for wavelengthNanometers in [380..780]
        response = matchingFunction.getValue wavelengthNanometers * 1e-9
        context.lineTo wavelengthNanometers, 400 - response * 50

      context.strokeStyle = colors[matchingFunctionLetter]
      context.stroke()

    # Restore to no clipping.
    context.restore()

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 380, 0, 400, 400
