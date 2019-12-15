AM = Artificial.Mirage
AS = Artificial.Spectrum

class AS.Pages.Color.Chromaticity extends AM.Component
  @register 'Artificial.Spectrum.Pages.Color.Chromaticity'

  constructor: (@app) ->
    super arguments...

  onRendered: ->
    super arguments...

    @drawColorMatchingFunctions()
    @drawChromaticityDiagram()
    
  drawColorMatchingFunctions: ->
    canvas = @$('.color-matching-functions')[0]
    context = canvas.getContext '2d'

    # Prepare coordinate system.
    context.translate -380 + 50 + 0.5, 10 + 0.5
    context.lineWidth = 1

    getCanvasY = (y) => (2 - y) * 100

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "λ (nm)", 580, 240

    context.beginPath()

    for wavelengthNanometers in [400..750] by 50
      # Draw a vertical line.
      context.moveTo wavelengthNanometers, 0
      context.lineTo wavelengthNanometers, 200

      # Write the number on the axis.
      context.textAlign = 'center'
      context.fillText wavelengthNanometers, wavelengthNanometers, 216

    context.strokeStyle = 'lightslategrey'
    context.stroke()

    for y in [0..200] by 50
      if 0 < y < 200
        # Draw a horizontal line.
        context.moveTo 380, y
        context.lineTo 780, y

      # Write the number on the axis.
      context.textAlign = 'right'
      context.fillText "#{y / 100}", 372, 200 - y + 4

    context.stroke()

    # Draw color matching functions.
    colors =
      x: 'firebrick'
      y: 'limegreen'
      z: 'darkblue'

    for matchingFunctionLetter in ['x', 'y', 'z']
      matchingFunction = AS.Color.CIE1931.ColorMatchingFunctions[matchingFunctionLetter].bind AS.Color.CIE1931.ColorMatchingFunctions

      context.beginPath()

      for wavelengthNanometers in [380..780]
        response = matchingFunction wavelengthNanometers
        context.lineTo wavelengthNanometers, getCanvasY response

      context.strokeStyle = colors[matchingFunctionLetter]
      context.stroke()

    # Stroke the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 380, 0, 400, 200

  drawChromaticityDiagram: ->
    canvas = @$('.chromaticity-diagram')[0]
    context = canvas.getContext '2d'

    # Prepare coordinate system.
    context.scale 4, 4
    context.translate 12.5 + 1 / 8, 2.5 + 1 / 8
    context.lineWidth = 1 / 4

    getCanvasX = (x) => x * 100 + 10
    getCanvasY = (y) => (1 - y) * 100 - 10

    # Draw scale.
    context.strokeStyle = 'ghostwhite'
    context.fillStyle = 'ghostwhite'
    context.strokeRect 0, 0, 100, 100

    context.font = '3px "Source Sans Pro", sans-serif'

    context.textAlign = 'right'
    context.fillText "y", -9, 51

    context.textAlign = 'center'
    context.fillText "x", 50, 110

    context.beginPath()

    for i in [10..100] by 10
      if i < 100
        # Draw a horizontal line.
        context.moveTo 0, i
        context.lineTo 100, i

        # Draw a vertical line.
        context.moveTo i, 0
        context.lineTo i, 100

      # Write the numbers on each axis.
      number = "#{((i - 10) / 100)}"

      context.textAlign = 'right'
      context.fillText number, -2, 100 - i + 1

      context.textAlign = 'center'
      context.fillText number, i, 104

    context.strokeStyle = 'lightslategrey'
    context.stroke()

    # Draw spectral locus.
    labelDashesPath = new Path2D
    labelDashLength = 0.02
    labelTextSpacing = 0.03
    context.textAlign = 'center'

    context.beginPath()

    for wavelengthNanometers in [380..780]
      chromaticity = nextChromaticity or AS.Color.CIE1931.getChromaticityForWavelength wavelengthNanometers / 1e9
      context.lineTo getCanvasX(chromaticity.x), getCanvasY(chromaticity.y)

      nextChromaticity = AS.Color.CIE1931.getChromaticityForWavelength (wavelengthNanometers + 1) / 1e9

      # Draw a label dash perpendicular to the spectral locus line.
      labelDashesPath.moveTo getCanvasX(chromaticity.x), getCanvasY(chromaticity.y)

      direction = new THREE.Vector2 nextChromaticity.x - chromaticity.x, nextChromaticity.y - chromaticity.y
      direction.normalize()
      direction.set -direction.y, direction.x

      dashLength = if  wavelengthNanometers % 10 is 0 then labelDashLength else labelDashLength * 0.3

      dashEnd =
        x: chromaticity.x + direction.x * dashLength
        y: chromaticity.y + direction.y * dashLength

      labelDashesPath.lineTo getCanvasX(dashEnd.x), getCanvasY(dashEnd.y)

      if wavelengthNanometers % 10 is 0 and 450 <= wavelengthNanometers <= 630
        # Write the label text.
        labelPosition =
          x: dashEnd.x + direction.x * labelTextSpacing
          y: dashEnd.y + direction.y * labelTextSpacing

        context.fillText wavelengthNanometers, getCanvasX(labelPosition.x), getCanvasY(labelPosition.y) + 1

    context.strokeStyle = 'gainsboro'
    context.stroke()

    context.strokeStyle = 'ghostwhite'
    context.stroke labelDashesPath

  _drawPoint: (context, x, y, radius) ->
    context.beginPath()
    context.arc x, y, radius, 0, Math.PI * 2
    context.fill()
