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
    
    displayedCriterion = @options.displayedCriterion()
    displayedCategoryValue = @options.displayedCategoryValue()
    displayedPixel = @options.displayedPixel()
    
    if displayedCriterion
      # When we're asked to display a specific criterion, just draw that one.
      enabledCriteria = [displayedCriterion]
      
    else if displayedPixel
      # Draw all criteria when we're asked to display a pixel.
      enabledCriteria = _.keys PAG.Criteria
      
    else
      return
      
    if displayedPixel
      # Draw all the line parts that cross the displayed pixels.
      lineParts = pixelArtGrading.getLinePartsAt displayedPixel.x, displayedPixel.y
      
      # If no lines are under the pixel, draw all the lines when a criterion is selected.
      return unless lineParts.length or displayedCriterion
      
    unless lineParts?.length
      lineParts = []
      
      for line in pixelArtGrading.lines
        for part in line.parts
          # Filter to evaluated property if needed.
          continue if displayedCategoryValue and part.grade()[displayedCategoryValue.property]?.type isnt displayedCategoryValue.value

          lineParts.push part
      
    markup = []
  
    # Add markup for even diagonals.
    if PAG.Criteria.EvenDiagonals in enabledCriteria
      for linePart in lineParts when linePart instanceof PAG.Line.Part.StraightLine
        markup.push Markup.PixelArt.intendedLine linePart
        
    @drawMarkup markup, context, renderOptions

  _addPixelToPath: (context, pixel) ->
    context.rect pixel.x, pixel.y, 1, 1

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
