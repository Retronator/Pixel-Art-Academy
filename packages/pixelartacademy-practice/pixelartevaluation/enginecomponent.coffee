AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

Markup = PAA.Practice.Helpers.Drawing.Markup

class PAE.EngineComponent extends PAA.Practice.Helpers.Drawing.Markup.EngineComponent
  @debug = true
  
  constructor: ->
    super arguments...
    
    @ready = new ComputedField =>
      return unless @options.pixelArtEvaluation()
      return unless LOI.palette()

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()
    
    @_pixelSize = 1 / renderOptions.camera.effectiveScale()
    
    @_render context, renderOptions

  _render: (context, renderOptions) ->
    pixelArtEvaluation = @options.pixelArtEvaluation()
    
    displayedCriteria = @options.displayedCriteria()
    filterValue = @options.filterValue()
    focusedPixel = @options.focusedPixel()
    
    markup = []
    
    # Add markup for pixel-perfect lines.
    if PAE.Criteria.PixelPerfectLines in displayedCriteria
      focusedLines = if focusedPixel then pixelArtEvaluation.getLinesAt focusedPixel.x, focusedPixel.y else []
      
      for layer in pixelArtEvaluation.layers
        for line in layer.lines
          continue if focusedLines.length and line not in focusedLines
          
          # Draw doubles and corners.
          drawDoubles = if filterValue then filterValue is PAE.Subcriteria.PixelPerfectLines.Doubles else true
          drawCorners = if filterValue then filterValue is PAE.Subcriteria.PixelPerfectLines.Corners else true
          
          markup.push Markup.PixelArt.pixelPerfectLineErrors(line, drawDoubles, drawCorners)...
          
    # Prepare line parts for markup.
    focusedLineParts = if focusedPixel then pixelArtEvaluation.getLinePartsAt focusedPixel.x, focusedPixel.y else []
    lineParts = []
    
    for layer in pixelArtEvaluation.layers
      for line in layer.lines
        for part in line.parts
          # Filter to evaluated property if needed.
          continue if filterValue and part.evaluate()[filterValue.property]?.type isnt filterValue.value
  
          lineParts.push part
        
    # Add markup for even diagonals.
    if PAE.Criteria.EvenDiagonals in displayedCriteria
      for linePart in lineParts when linePart instanceof PAE.Line.Part.StraightLine
        if linePart in focusedLineParts
          markup.push Markup.PixelArt.straightLineBreakdown(linePart)...
          
        else
          markup.push Markup.PixelArt.evaluatedImpliedStraightLine(linePart)...
      
      # If we're not going to be drawing curves, draw a faint unevaluated outline to indicate they were detected.
      unless PAE.Criteria.SmoothCurves in displayedCriteria
        for linePart in lineParts when linePart instanceof PAE.Line.Part.Curve
          curveMarkup = Markup.PixelArt.impliedCurve linePart
          curveMarkup.line.width = 0
          markup.push curveMarkup
          
    @drawMarkup markup, context, renderOptions

  _addPixelToPath: (context, pixel) ->
    context.rect pixel.x - 0.5, pixel.y - 0.5, 1, 1

  _diagonalDash: (context, bounds, color) ->
    context.save()
    context.clip()
    context.strokeStyle = color
    context.lineWidth = @_pixelSize
    context.beginPath()
    
    for x in [-bounds.height...bounds.width] by 5 * @_pixelSize
      context.moveTo x, 0
      context.lineTo x + bounds.height, bounds.height
      
    context.stroke()
    context.restore()
  
  _bezierCurve: (context, controlPoint1, controlPoint2, end) ->
    context.bezierCurveTo controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, end.x, end.y
