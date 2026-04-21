AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
RA = PAA.Practice.ReadabilityAnalysis
PAE = PAA.Practice.PixelArtEvaluation

Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

class RA.EngineComponent extends PAA.Practice.Helpers.Drawing.Markup.EngineComponent
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
