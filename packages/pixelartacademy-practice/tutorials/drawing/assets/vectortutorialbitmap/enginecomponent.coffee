PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap.EngineComponent
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless svgData = @options.svgData()

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()
