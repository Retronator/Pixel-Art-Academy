AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AR.Pages.Chemistry.Gases extends AR.Pages.Chemistry.Gases
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

    xAxisPropertyFieldName = @constructor.PropertyFieldNames[xAxisProperty]
    yAxisPropertyFieldName = @constructor.PropertyFieldNames[yAxisProperty]

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
    context.fillText "#{yAxisScale.name} (#{yAxisScale.unit})", -(graphSize / 2) - 10, 30
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

    # Clip drawing to the graph area.
    context.save()
    context.beginPath()
    context.rect 0, 0, graphSize, graphSize
    context.clip()

    # Draw ideal gas line.
    gasState = @getGasState()
    context.beginPath()

    for x in [0...graphSize]
      xValue = x / graphSize * xAxisScale.range

      if yAxisProperty is xAxisProperty
        yValue = xValue

      else
        gasState[xAxisPropertyFieldName] = xValue

        switch yAxisProperty
          when @constructor.Properties.Volume
            yValue = gasState.amountOfSubstance * AR.GasConstant * gasState.temperature / gasState.pressure

          when @constructor.Properties.Pressure
            yValue = gasState.amountOfSubstance * AR.GasConstant * gasState.temperature / gasState.volume

          when @constructor.Properties.AmountOfSubstance
            yValue = gasState.pressure * gasState.volume / (AR.GasConstant * gasState.temperature)

          when @constructor.Properties.Temperature
            yValue = gasState.pressure * gasState.volume / (AR.GasConstant * gasState.amountOfSubstance)

      context.lineTo x, getCanvasY(yValue)

    context.setLineDash [3, 3]
    context.strokeStyle = 'gainsboro'
    context.stroke()
    context.setLineDash []

    # Draw actual gas line.
    gasClass = @gasClass()
    context.beginPath()

    for x in [0...graphSize]
      xValue = x / graphSize * xAxisScale.range

      if yAxisProperty is xAxisProperty
        yValue = xValue

      else
        gasState[xAxisPropertyFieldName] = xValue
        yValue = gasClass["get#{yAxisProperty}ForState"] gasState

      context.lineTo x, getCanvasY yValue or 0

    context.strokeStyle = 'ghostwhite'
    context.stroke()

    # Draw point on graph.
    gasState = @getGasState()
    point =
      x: gasState[xAxisPropertyFieldName]
      y: gasState[yAxisPropertyFieldName]

    if point.x? and point.y?
      context.fillStyle = "white"
      @_drawPoint context, getCanvasX(point.x), getCanvasY(point.y), 4

    # Restore to no clipping.
    context.restore()

    # Draw the border.
    context.strokeStyle = 'ghostwhite'
    context.strokeRect 0, 0, graphSize, graphSize
