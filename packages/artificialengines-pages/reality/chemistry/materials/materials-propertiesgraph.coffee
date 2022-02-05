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
    context.fillStyle = 'slategray'
    context.fillRect 0, 0, canvas.width, canvas.height

    # Prepare coordinate system.
    context.translate -380 + 30 + 0.5, 10 + 0.5

    yAxis =
      maxValue: 5
      spacing: 0.5

    getCanvasY = (y) => (yAxis.maxValue - y) * (400 / yAxis.maxValue)

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "wavelength (nm)", 580, 440

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

    # Draw legend.
    reflectanceIncidentAngle = @reflectanceIncidentAngle()
    reflectanceIncidentAngleDegrees = Math.round reflectanceIncidentAngle / Math.PI * 180

    properties =
      refractiveIndex:
        name: 'refractive index'
        color: 'Silver'

      extinctionCoefficient:
        name: 'extinction coefficient'
        color: 'DarkSlateGray'

    drawTransmission = @previewType() is @constructor.PreviewTypes.Dispersion
    transmissionDepth = @transmissionDepth()

    if drawTransmission
      properties.transmission =
        name: if reflectanceIncidentAngleDegrees then "transmission at #{reflectanceIncidentAngleDegrees}°" else 'transmission at normal incidence'
        color: 'LightSkyBlue'

      if transmissionDepth
        transmissionDepthNanometers = Math.round transmissionDepth * 1e9

        properties.transmission.name += ", #{transmissionDepthNanometers} nm deep"

    else
      properties.reflection =
        name: if reflectanceIncidentAngleDegrees then "reflectance at #{reflectanceIncidentAngleDegrees}°" else 'reflectance at normal incidence'
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
        value = getCanvasY spectrum.getValue wavelength
        context.lineTo wavelengthNanometers, value if value?

      context.stroke()

    # Draw reflectance or transmission at given incidence.
    reflectanceType = @reflectanceType()

    spectrum = new AR.Optics.Spectrum.Formulated (wavelength) =>
      refractiveIndexMaterial = refractiveIndexSpectrum.getValue wavelength
      extinctionCoefficientMaterial = extinctionCoefficientSpectrum?.getValue wavelength

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

      if drawTransmission
        absorptance = AR.Optics.FresnelEquations.getAbsorptance reflectanceIncidentAngle, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2

        attenuationCoefficient = 4 * Math.PI * extinctionCoefficient2 / wavelength
        attenuation = Math.E ** (-attenuationCoefficient * transmissionDepth)

        absorptance * attenuation

      else
        AR.Optics.FresnelEquations.getReflectance reflectanceIncidentAngle, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2

    # Color area under spectrum line.
    context.globalCompositeOperation = 'screen'

    for wavelengthNanometers in [380..780]
      wavelength = wavelengthNanometers / 1e9
      reflectanceAtNormalIncidence = spectrum.getValue wavelength
      y = getCanvasY reflectanceAtNormalIncidence

      # Color area under histogram with wavelength color.
      rgb = AS.Color.SRGB.getGammaRGBForNormalizedRGB AS.Color.SRGB.getRGBForXYZ AS.Color.XYZ.getRelativeXYZForWavelength wavelength
      context.fillStyle = "rgba(#{rgb.r * 255}, #{rgb.g * 255}, #{rgb.b * 255}, 0.5)"

      height = getCanvasY(0) - y
      context.fillRect wavelengthNanometers - 0.5, y, 1, height

    context.globalCompositeOperation = 'source-over'

    # Draw line for reflectance.
    context.strokeStyle = (properties.reflection or properties.transmission).color
    drawSpectrum context, spectrum

    # Draw refractive index.
    context.strokeStyle = properties.refractiveIndex.color
    drawSpectrum context, refractiveIndexSpectrum

    # Draw extinction coefficient.
    if extinctionCoefficientSpectrum
      context.strokeStyle = properties.extinctionCoefficient.color
      drawSpectrum context, new AR.Optics.Spectrum.Formulated (wavelength) => extinctionCoefficientSpectrum.getValue(wavelength)

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
