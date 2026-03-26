AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
RA = PAA.Practice.ReadabilityAnalysis
PAE = PAA.Practice.PixelArtEvaluation

Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

_lineColor = new THREE.Color

class RA.EngineComponent extends PAA.Practice.Helpers.Drawing.Markup.EngineComponent
  @debug = true

  constructor: (@options) ->
    super arguments...
    
    @ready = new ComputedField =>
      return unless @options.readabilityAnalysis()?.regions
      return unless LOI.palette()

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()
    
    @_pixelSize = 1 / renderOptions.camera.effectiveScale()
    
    @_render context, renderOptions

  _render: (context, renderOptions) ->
    return unless @options.displayed()
    
    readabilityAnalysis = @options.readabilityAnalysis()
    pixelArtEvaluation = readabilityAnalysis.pixelArtEvaluation

    palette = LOI.palette()
    bestColor = palette.color Atari2600.hues.green, 4
    betterColor = palette.color Atari2600.hues.aqua, 4
    neutralColor = palette.color Atari2600.hues.azure, 5
    worseColor = palette.color Atari2600.hues.yellow, 5
    worstColor = palette.color Atari2600.hues.peach, 5
    
    markup = []

    # Prepare lines and line parts for markup.
    focusedPixel = @options.focusedPixel()
    focusedLines = if focusedPixel then pixelArtEvaluation.getLinesAt focusedPixel.x, focusedPixel.y else []
    focusedPoints = if focusedPixel then pixelArtEvaluation.getPointsAt focusedPixel.x, focusedPixel.y else []
    focusedElements = [focusedLines..., focusedPoints...]
    
    for region in readabilityAnalysis.regions
      for strokeAnalysis in region.strokes
        if strokeAnalysis.element instanceof PAE.Line
          line = strokeAnalysis.element
          continue if focusedElements.length and line not in focusedElements
          
        if strokeAnalysis.element instanceof PAE.Point
          point = strokeAnalysis.element
          continue if focusedElements.length and point not in focusedElements
        
        if strokeAnalysis.probabilityChange.symbolic > 0.1
          _lineColor.copy bestColor
          
        else if strokeAnalysis.probabilityChange.symbolic > 0.01
          _lineColor.copy betterColor
          
        else if strokeAnalysis.probabilityChange.symbolic < -0.1
          _lineColor.copy worstColor
          
        else if strokeAnalysis.probabilityChange.symbolic < -0.01
          _lineColor.copy worseColor
          
        else
          _lineColor.copy neutralColor
          
        style = "##{_lineColor.getHexString()}"
        
        if line
          lineMarkup = Markup.PixelArt.perceivedLine line
          
          for element in lineMarkup
            element.line.style = style
            element.line.width = 2
            
          markup.push lineMarkup...
        
        if point
          markup.push
            circle:
              x: point.x + 0.5
              y: point.y + 0.5
              radius: point.radius * 0.5
              style: style
          
    @drawMarkup markup, context,
      pixelSize: 1 / renderOptions.camera.effectiveScale() * devicePixelRatio
      displayPixelSize: 1 / renderOptions.camera.effectiveScale() * renderOptions.editor.display.scale()
