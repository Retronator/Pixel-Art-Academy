AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AR.Pages.Chemistry.Materials extends AR.Pages.Chemistry.Materials
  drawReflectanceGraph: ->
    canvas = @$('.reflectance-graph')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    # Prepare coordinate system.
    context.translate 50 + 0.5, 10 + 0.5

    yAxis =
      maxValue: 1
      spacing: 0.1

    getCanvasX = (incidentAngleDegrees) => incidentAngleDegrees * 2
    getCanvasY = (y) => (1 - y / 100) * 180

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "incident angle (°)", 90, 220

    context.save()
    context.setTransform 1, 0, 0, 1, 0, 0
    context.rotate -Math.PI / 2
    context.fillText "Reflectance (%)", -100, 20
    context.restore()

    context.beginPath()

    for incidentAngleDegrees in [0..90] by 10
      canvasX = getCanvasX incidentAngleDegrees

      # Draw a vertical line.
      context.moveTo canvasX, 0
      context.lineTo canvasX, 180

      # Write the number on the axis.
      context.textAlign = 'center'
      context.fillText incidentAngleDegrees, incidentAngleDegrees * 2, 196

    context.strokeStyle = 'lightslategrey'
    context.stroke()

    for y in [0..100] by 10
      canvasY = getCanvasY y

      # Draw a horizontal line.
      context.moveTo 0, canvasY
      context.lineTo 180, canvasY

      # Write the number on the axis.
      context.textAlign = 'right'

      context.fillText y, -8, canvasY + 4

    context.stroke()

    # Draw graph.
    reflectanceType = @reflectanceType()
    wavelength = @reflectanceWavelengthNanometers() / 1e9

    materialClass = @materialClass()
    refractiveIndexSpectrum = materialClass.getRefractiveIndexSpectrum()
    extinctionCoefficientSpectrum = materialClass.getExtinctionCoefficientSpectrum()

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

    reflectanceLines = [
      method: 'getReflectanceS'
      lineDash: []
    ,
      method: 'getReflectanceP'
      lineDash: []
    ,
      method: 'getReflectance'
      lineDash: [3, 3]
    ]

    context.strokeStyle = 'LightSkyBlue'

    for line in reflectanceLines
      context.beginPath()

      for incidentAngleDegrees in [0..90] by 0.5
        incidentAngle = incidentAngleDegrees / 180 * Math.PI
        reflectance = AR.Optics.FresnelEquations[line.method] incidentAngle, refractiveIndex1, refractiveIndex2, extinctionCoefficient1, extinctionCoefficient2

        x = getCanvasX incidentAngleDegrees
        y = getCanvasY reflectance * 100

        context.lineTo x, y

      context.setLineDash line.lineDash
      context.stroke()

    context.setLineDash []

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 0, 0, 180, 180
