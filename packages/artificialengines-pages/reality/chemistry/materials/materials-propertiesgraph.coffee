AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AR.Pages.Chemistry.Materials extends AR.Pages.Chemistry.Materials
  drawPropertiesGraph: ->
    canvas = @$('.properties-graph')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0

    # Color the canvas the same as the background. We do not want
    # transparent color so that we can do blending operations over it.
    context.fillStyle = 'slategrey'
    context.fillRect 0, 0, canvas.width, canvas.height

    # Prepare coordinate system.
    context.translate -380 + 30 + 0.5, 10 + 0.5

    yAxis =
      maxValue: 4
      spacing: 0.5

    getCanvasY = (y) => (yAxis.maxValue - y) * (400 / yAxis.maxValue)

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "λ (nm)", 580, 440

    context.beginPath()

    for wavelengthNanometers in [400..750] by 50
      # Draw a vertical line.
      context.moveTo wavelengthNanometers, 0
      context.lineTo wavelengthNanometers, 400

      # Write the number on the axis.
      context.textAlign = 'center'
      context.fillText wavelengthNanometers, wavelengthNanometers, 416

    context.strokeStyle = 'lightslategrey'
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

    # Draw legend.
    properties =
      refractiveIndex:
        name: 'refractive index'
        color: 'Silver'

      extinctionCoefficient:
        name: 'extinction coefficient (1/mm)'
        color: 'DarkSlateGray'

      reflectionAtNormalIncidence:
        name: 'reflectance at normal incidence'
        color: 'LightSkyBlue'

    legendPosition =
      top: 10
      left: 390

    lineLength = 20

    context.lineWidth = 2
    context.textAlign = 'left'

    for property, index in _.values properties
      context.beginPath()
      y = legendPosition.top + index * 20 + 3.5
      context.moveTo legendPosition.left, y
      context.lineTo legendPosition.left + lineLength, y
      context.strokeStyle = property.color
      context.stroke()

      context.fillText property.name, legendPosition.left + lineLength + 5, y + 4

    context.lineWidth = 1

    # Clip drawing to the graph area.
    context.save()
    context.beginPath()
    context.rect 380, 0, 400, 400
    context.clip()

    # Draw properties.
    materialClass = @materialClass()
    refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
    extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

    context.lineWidth = 2

    drawSpectrum = (context, spectrum) =>
      context.beginPath()

      for wavelengthNanometers in [380..780]
        wavelength = wavelengthNanometers / 1e9
        value = getCanvasY spectrum wavelength
        context.lineTo wavelengthNanometers, value if value?

      context.stroke()

    # Draw reflectance at normal incidence.
    reflectanceType = @reflectanceType()

    reflectanceAtNormalIncidenceSpectrum = (wavelength) =>
      refractiveIndexMaterial = refractiveIndexSpectrum wavelength
      extinctionCoefficientMaterial = extinctionCoefficientSpectrum? wavelength

      switch reflectanceType
        when @constructor.ReflectanceTypes.VacuumToMaterial
          # We're going from vacuum (ri = 1 + 0i) into the material.
          refractiveIndex1 = 1
          extinctionCoefficient1 = 0

          refractiveIndex2 = refractiveIndexMaterial
          extinctionCoefficient2 = extinctionCoefficientMaterial

        when @constructor.ReflectanceTypes.MaterialToVacuum
          # We're going the opposite way.
          refractiveIndex1 = refractiveIndexMaterial
          extinctionCoefficient1 = extinctionCoefficientMaterial

          refractiveIndex2 = 1
          extinctionCoefficient2 = 0

      AR.Optics.FresnelEquations.getReflectance 0, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2

    # Color area under reflectance.
    context.globalCompositeOperation = 'screen'

    for wavelengthNanometers in [380..780]
      wavelength = wavelengthNanometers / 1e9
      reflectanceAtNormalIncidence = reflectanceAtNormalIncidenceSpectrum wavelength
      y = getCanvasY reflectanceAtNormalIncidence

      # Color area under histogram with wavelength color.
      rgb = AS.Color.SRGB.getRGBForLinearRGB AS.Color.SRGB.getLinearRGBForNormalizedXYZ AS.Color.CIE1931.getRelativeXYZForWavelength wavelength
      context.fillStyle = "rgba(#{rgb.r * 255}, #{rgb.g * 255}, #{rgb.b * 255}, 0.5)"

      height = getCanvasY(0) - y
      context.fillRect wavelengthNanometers - 0.5, y, 1, height

    context.globalCompositeOperation = 'source-over'

    # Draw line for reflectance.
    context.strokeStyle = properties.reflectionAtNormalIncidence.color
    drawSpectrum context, reflectanceAtNormalIncidenceSpectrum

    # Draw refractive index.
    context.strokeStyle = properties.refractiveIndex.color
    drawSpectrum context, refractiveIndexSpectrum

    # Draw extinction coefficient.
    if extinctionCoefficientSpectrum
      context.strokeStyle = properties.extinctionCoefficient.color
      drawSpectrum context, (wavelength) => extinctionCoefficientSpectrum(wavelength) / 1e3

    # Draw reflectance wavelength.
    wavelengthNanometers = @reflectanceWavelengthNanometers()

    context.beginPath()
    context.moveTo wavelengthNanometers, 0
    context.lineTo wavelengthNanometers, 400

    context.globalAlpha = 0.5
    context.lineWidth = 1
    context.strokeStyle = 'ghostwhite'
    context.stroke()
    context.globalAlpha = 1

    # Restore to no clipping.
    context.restore()

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 380, 0, 400, 400
