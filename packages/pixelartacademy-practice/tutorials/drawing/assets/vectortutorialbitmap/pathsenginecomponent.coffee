PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap.PathsEngineComponent
  @debug = false
  
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless @options.svgPaths()

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()
    
    pixelSize = 1 / renderOptions.camera.effectiveScale()
    
    svgPaths = @options.svgPaths()
    currentActivePathIndex = @options.currentActivePathIndex()
    
    if @constructor.debug
      context.globalAlpha = 0.5
      context.imageSmoothingEnabled = false
      
      if paths = @options.paths()
        for pathIndex in [0..currentActivePathIndex]
          context.drawImage paths[pathIndex].canvas, 0, 0
          
      context.globalAlpha = 1
    
    context.save()
    halfPixelSize = pixelSize / 2
    context.translate halfPixelSize, halfPixelSize

    context.lineWidth = pixelSize
    
    # Determine path opacity.
    pathOpacity = Math.min 1, renderOptions.camera.scale() / 4
    context.strokeStyle = "lch(50% 0 0 / #{pathOpacity})"
    
    for pathIndex in [0..currentActivePathIndex]
      path = new Path2D svgPaths[pathIndex].getAttribute 'd'
      context.stroke path

    context.restore()
