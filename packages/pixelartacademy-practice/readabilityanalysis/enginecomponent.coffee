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

    palette = LOI.palette()
    bestColor = palette.color Atari2600.hues.green, 4
    betterColor = palette.color Atari2600.hues.aqua, 4
    neutralColor = palette.color Atari2600.hues.azure, 5
    worseColor = palette.color Atari2600.hues.yellow, 5
    worstColor = palette.color Atari2600.hues.peach, 5
    
    markup = []

    for region in readabilityAnalysis.regions
      for strokeAnalysis in region.strokes
        probabilityChange = Math.max strokeAnalysis.probabilityChange.symbolic, strokeAnalysis.probabilityChange.realistic
        
        if probabilityChange > 0.1
          _lineColor.copy bestColor
          
        else if probabilityChange > 0.01
          _lineColor.copy betterColor
          
        else if probabilityChange < -0.1
          _lineColor.copy worstColor
          
        else if probabilityChange < -0.01
          _lineColor.copy worseColor
          
        else
          _lineColor.copy neutralColor
          
        markup.push
          line:
            style: "##{_lineColor.getHexString()}"
            width: 2
            cap: 'round'
            points: strokeAnalysis.vertices
          
    @drawMarkup markup, context,
      pixelSize: 1 / renderOptions.camera.effectiveScale() * devicePixelRatio
      displayPixelSize: 1 / renderOptions.camera.effectiveScale() * renderOptions.editor.display.scale()
