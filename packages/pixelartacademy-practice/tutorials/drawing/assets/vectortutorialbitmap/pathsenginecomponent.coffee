PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Tutorials.Drawing.Assets.VectorTutorialBitmap.PathsEngineComponent
  @debug = false
  
  constructor: (@options) ->
    @ready = new ComputedField =>
      return unless @options.svgPathGroups()

      true

  drawToContext: (context, renderOptions = {}) ->
    return unless @ready()
    
    pixelSize = 1 / renderOptions.camera.effectiveScale()
    
    svgPathGroups = @options.svgPathGroups()
    currentActivePathIndex = @options.currentActivePathIndex()
    
    if @constructor.debug
      context.globalAlpha = 0.5
      context.imageSmoothingEnabled = false
      
      paths = @options.paths()
      
      if paths?.length
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
    
    pathsDrawnCount = 0
    
    for svgPathGroup in svgPathGroups
      context.save()
      context.translate svgPathGroup.offset.x, svgPathGroup.offset.y if svgPathGroup.offset
      
      for svgPath in svgPathGroup.svgPaths
        path = new Path2D svgPath.getAttribute 'd'
        context.stroke path
        pathsDrawnCount++
        
        break if pathsDrawnCount > currentActivePathIndex

      context.restore()
      break if pathsDrawnCount > currentActivePathIndex

    context.restore()
