AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AR.Pages.Chemistry.Gases extends AR.Pages.Chemistry.Gases
  @register 'Artificial.Reality.Pages.Chemistry.Gases'

  drawPropertiesGraph: ->
    canvas = @$('.properties-graph')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height

    # Prepare coordinate system.
    context.translate 70 + 0.5, 10 + 0.5

    graphSize = 400

    xAxisProperty = @xAxisProperty()
    yAxisProperty = @yAxisProperty()

    xAxisScale = @constructor.Scales[xAxisProperty]
    yAxisScale = @constructor.Scales[yAxisProperty]

    getCanvasX = (x) => x / xAxisScale.range * graphSize
    getCanvasY = (y) => graphSize - y / yAxisScale.range * graphSize

    # Draw scale.
    context.fillStyle = 'ghostwhite'
    context.font = '12px "Source Sans Pro", sans-serif'

    context.textAlign = 'center'
    context.fillText "#{xAxisScale.name} (#{xAxisScale.unit})", graphSize / 2, graphSize + 40

    context.save()
    context.setTransform 1, 0, 0, 1, 0, 0
    context.rotate -Math.PI / 2
    context.fillText "#{yAxisScale.name} (#{yAxisScale.unit})", -(graphSize / 2), 30
    context.restore()

    context.beginPath()

    formatAxisNumber = (number) ->
      if Math.round(number * 10) % 10
        number.toFixed 1

      else
        number.toFixed 0

    for x in [0..10]
      offset = x / 10 * graphSize

      # Draw a vertical line.
      context.moveTo offset, 0
      context.lineTo offset, graphSize

      # Draw a horizontal line.
      context.moveTo 0, offset
      context.lineTo graphSize, offset

      # Write the number on the x axis.
      context.textAlign = 'center'
      xNumber = x / 10 / (xAxisScale.multiplier or 1) * xAxisScale.range
      context.fillText formatAxisNumber(xNumber), offset, graphSize + 16

      # Write the number on the y axis.
      context.textAlign = 'right'
      y = 10 - x
      yNumber = y / 10 / (yAxisScale.multiplier or 1) * yAxisScale.range
      context.fillText formatAxisNumber(yNumber), -8, offset + 4

    context.strokeStyle = 'lightslategrey'
    context.stroke()

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 0, 0, graphSize, graphSize
