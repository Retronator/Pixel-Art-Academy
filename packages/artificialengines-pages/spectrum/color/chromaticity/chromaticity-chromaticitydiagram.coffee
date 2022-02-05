AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AS.Pages.Color.Chromaticity extends AS.Pages.Color.Chromaticity
  @register 'Artificial.Spectrum.Pages.Color.Chromaticity'

  prepareSRGBimage: ->
    canvasSize = 400

    @sRGBImage = new AM.Canvas canvasSize, canvasSize
    @sRGBImage.context.scale canvasSize, canvasSize

    rgbs = []

    for i in [0..255]
      for j in [0..255]
        rgbs.push r: 1, g: i / 255, b: j / 255
        rgbs.push r: i / 255, g: 1, b: j / 255
        rgbs.push r: i / 255, g: j / 255, b: 1

    for rgb in rgbs
      linearRGB = AS.Color.SRGB.getNormalizedRGBForGammaRGB rgb
      xyz = AS.Color.SRGB.getXYZForNormalizedRGB linearRGB
      chromaticity = AS.Color.XYZ.getChromaticityForXYZ xyz
      @sRGBImage.context.fillStyle = "rgb(#{rgb.r * 255}, #{rgb.g * 255}, #{rgb.b * 255})"

      @_drawPoint @sRGBImage.context, chromaticity.x, 1 - chromaticity.y, 0.0025

  drawChromaticityDiagram: ->
    canvas = @$('.chromaticity-diagram')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    # Prepare coordinate system.
    context.scale 4, 4
    context.translate 12.5 + 1 / 8, 2.5 + 1 / 8
    context.lineWidth = 1 / 4

    getCanvasX = (x) => x * 100 + 10
    getCanvasY = (y) => (1 - y) * 100 - 10

    # Draw scale.
    context.strokeStyle = 'ghostwhite'
    context.fillStyle = 'ghostwhite'

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

    context.strokeStyle = 'lightslategray'
    context.stroke()

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 0, 0, 100, 100

    # Draw spectral locus.
    labelDashesPath = new Path2D
    labelDashLength = 0.02
    labelTextSpacing = 0.03
    context.textAlign = 'center'

    context.beginPath()

    for wavelengthNanometers in [380..780]
      chromaticity = nextChromaticity or AS.Color.XYZ.getChromaticityForWavelength wavelengthNanometers / 1e9
      context.lineTo getCanvasX(chromaticity.x), getCanvasY(chromaticity.y)

      nextChromaticity = AS.Color.XYZ.getChromaticityForWavelength (wavelengthNanometers + 1) / 1e9

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

    # Draw sRGB triangle.
    context.globalAlpha = 0.5
    context.drawImage @sRGBImage, getCanvasX(0), getCanvasY(1), 100, 100
    context.globalAlpha = 1

    rXYZ = AS.Color.SRGB.getXYZForNormalizedRGB r: 1, g: 0, b: 0
    gXYZ = AS.Color.SRGB.getXYZForNormalizedRGB r: 0, g: 1, b: 0
    bXYZ = AS.Color.SRGB.getXYZForNormalizedRGB r: 0, g: 0, b: 1

    context.beginPath()

    for xyz in [rXYZ, gXYZ, bXYZ]
      chromaticity = AS.Color.XYZ.getChromaticityForXYZ xyz
      context.lineTo getCanvasX(chromaticity.x), getCanvasY(chromaticity.y)

    context.closePath()
    context.lineWidth = 1 / 3
    context.strokeStyle = 'ghostwhite'
    context.stroke()

    # Draw position of light source.
    if xyz = @lightSourceXYZ()
      lightSourceChromaticity = AS.Color.XYZ.getChromaticityForXYZ xyz

      context.fillStyle = "white"
      @_drawPoint context, getCanvasX(lightSourceChromaticity.x), getCanvasY(lightSourceChromaticity.y), 1
