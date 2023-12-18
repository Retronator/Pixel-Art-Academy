AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

Markup = PAA.Practice.Helpers.Drawing.Markup

class PAG.EngineComponent extends PAA.Practice.Helpers.Drawing.Markup.EngineComponent
  @debug = true
  
  constructor: ->
    super arguments...
    
    @ready = new ComputedField =>
      return unless @options.pixelArtGrading()

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()
    
    @_pixelSize = 1 / renderOptions.camera.effectiveScale()
    
    @_render context, renderOptions

  _render: (context, renderOptions) ->
    pixelArtGrading = @options.pixelArtGrading()
    
    displayedCriteria = @options.displayedCriteria()
    filterToCategoryValue = @options.filterToCategoryValue()
    focusedPixel = @options.focusedPixel()
    
    focusedLineParts = if focusedPixel then pixelArtGrading.getLinePartsAt focusedPixel.x, focusedPixel.y else []
    lineParts = []
    
    for layer in pixelArtGrading.layers
      for line in layer.lines
        for part in line.parts
          # Filter to evaluated property if needed.
          continue if filterToCategoryValue and part.grade()[filterToCategoryValue.property]?.type isnt filterToCategoryValue.value
  
          lineParts.push part
      
    markup = []
  
    # Add markup for even diagonals.
    if PAG.Criteria.EvenDiagonals in displayedCriteria
      for linePart in lineParts when linePart instanceof PAG.Line.Part.StraightLine
        if linePart in focusedLineParts
          markup.push Markup.PixelArt.straightLineBreakdown(linePart)...
          
        else
          markup.push Markup.PixelArt.gradedIntendedLine(linePart)...
        
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
