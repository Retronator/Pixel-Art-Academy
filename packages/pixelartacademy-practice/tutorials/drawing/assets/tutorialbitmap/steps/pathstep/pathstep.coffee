AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

if Meteor.isClient
  require 'path-data-polyfill/path-data-polyfill.js'

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.PathStep extends TutorialBitmap.Step
  @debug = false
  
  @StrokeStyles =
    Solid: 'Solid'
    None: 'None'
    
  @FillStyles =
    Solid: 'Solid'
    Dashed: 'Dashed'
  
  @drawPathStrokeHints: (context, renderOptions, stepArea, paths, strokeWidth = 1) ->
    # Draw path to step area.
    context.save()
    context.translate stepArea.bounds.x, stepArea.bounds.y
    
    if @debug
      # Draw the anti-aliased paths for debug purposes.
      context.globalAlpha = 0.5
      context.imageSmoothingEnabled = false
      
      for path in paths
        context.drawImage path.canvas, 0, 0
      
      context.globalAlpha = 1

    # Draw all the paths' hints.
    path.drawStrokeHint context, renderOptions, strokeWidth for path in paths

    context.restore()
  
  @drawPathFillHints: (context, renderOptions, stepArea, paths) ->
    # Draw path to step area.
    context.save()
    context.translate stepArea.bounds.x, stepArea.bounds.y
    
    # Draw all the paths' hints.
    path.drawFillHint context, renderOptions for path in paths

    context.restore()
    
  # Note: We receive pure SVG paths through options since the SVG paths resource can be broken down into multiple steps.
  constructor: ->
    super arguments...
    
    @options.hasPixelsWhenInactive ?= true
    @options.tolerance ?= 0
    @options.hintStrokeWidth ?= 1
    @options.strokeStyle ?= @constructor.StrokeStyles.Solid
    @options.fillStyle ?= @constructor.FillStyles.Dashed
    
    @_pathsDependency = new Tracker.Dependency

    if _.isFunction @options.svgPaths
      @_initializePathsAutorun = Tracker.autorun =>
        @_initializePaths @options.svgPaths()
      
    else
      @_initializePaths @options.svgPaths
      
  destroy: ->
    @_initializePathsAutorun?.stop()
    
  # We separate the initialization part so we can reuse it in child implementations.
  _initializePaths: (svgPaths) ->
    @paths = for svgPath in svgPaths
      new @constructor.Path @tutorialBitmap, @, svgPath
      
    @_pixelsMap = new Uint8Array @stepArea.bounds.width * @stepArea.bounds.height
    
    width = @stepArea.bounds.width
    height = @stepArea.bounds.height
    
    for x in [0...width]
      for y in [0...height]
        for path in @paths when path.hasPixel x, y
          @_pixelsMap[x + y * width]++
  
    @_pathsDependency.changed()
  
  _pathsReady: ->
    @_pathsDependency.depend()
    @paths?.length
    
  completed: ->
    return unless @_pathsReady()
    return unless super arguments...

    # Check that all paths have their pixels covered. We check all paths instead of
    # quitting early since paths also remember their completed state for drawing hints.
    completed = true
    
    for path in @paths
      completed = false unless path.completed()
    
    completed
  
  hasPixel: (absoluteX, absoluteY) ->
    return unless @_pathsReady()
    return unless @options.hasPixelsWhenInactive or @isActiveStepInArea()
    
    relativeX = absoluteX - @stepArea.bounds.x
    relativeY = absoluteY - @stepArea.bounds.y
    
    @_pixelsMap[relativeX + relativeY * @stepArea.bounds.width] > 0
    
  multiplePathsHavePixel: (relativeX, relativeY) ->
    return unless @_pathsReady()
    @_pixelsMap[relativeX + relativeY * @stepArea.bounds.width] > 1
  
  solve: ->
    bitmap = @tutorialBitmap.bitmap()
    palette = @tutorialBitmap.palette()

    pixels = []
    width = @stepArea.bounds.width
    height = @stepArea.bounds.height
    
    for x in [0...width]
      for y in [0...height]
        paletteColor = null
        
        # Try fills first.
        for path in @paths when path.pixelExceedsSolutionThreshold(x, y) and path.pixelShouldBeFill x, y
          paletteColor = palette.exactPaletteColor path.fillColor
          break
          
        # Strokes override filles.
        for path in @paths when path.pixelExceedsSolutionThreshold(x, y) and not path.pixelShouldBeFill x, y
          paletteColor = palette.exactPaletteColor path.strokeColor
          break

        if paletteColor
          pixels.push
            x: x + @stepArea.bounds.x
            y: y + @stepArea.bounds.y
            paletteColor: paletteColor
    
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], pixels
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date
    
  drawUnderlyingHints: (context, renderOptions) ->
    return unless @_pathsReady()

    @constructor.drawPathFillHints context, renderOptions, @stepArea, @paths
  
  drawOverlaidHints: (context, renderOptions) ->
    return unless @_pathsReady()

    @constructor.drawPathStrokeHints context, renderOptions, @stepArea, @paths, @options.hintStrokeWidth

    @_prepareColorHelp context, renderOptions
    
    bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    palette = @tutorialBitmap.palette()
    backgroundColor = @tutorialBitmap.backgroundColor()
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        absoluteX = x + @stepArea.bounds.x
        absoluteY = y + @stepArea.bounds.y

        continue unless pixel = bitmapLayer.getPixel absoluteX, absoluteY
        
        if @stepArea.hasGoalPixel(absoluteX, absoluteY)
          # Draw hints if no path completed the pixel.
          pixelCompleted = false
          
          for path in @paths
            if path.pixelCompleted x, y
              pixelCompleted = true
              break
              
          continue if pixelCompleted
        
          # Draw hints at path pixels with the correct color.
          hintNeeded = true
          
          # In the first pass, try to draw only strokes.
          for path in @paths when path.pixelExceedsColorHintThreshold(x, y) and path.pixelCanBeStroke x, y
            hintNeeded = false

            # Nothing to do if the pixel already has the color of the path.
            break if LOI.Assets.ColorHelper.areAssetColorsEqual pixel, path.strokeColor, palette, backgroundColor
            
            # Draw the hint for this stroke color.
            @_drawColorHelpForPixel context, x, y, path.strokeAssetColor, palette, pixel, renderOptions
            break
            
          if hintNeeded
            # In the second pass, try to draw fill color hints.
            for path in @paths when path.pixelExceedsColorHintThreshold(x, y) and path.pixelCanBeFill x, y
              break if LOI.Assets.ColorHelper.areAssetColorsEqual pixel, path.fillColor, palette, backgroundColor
              
              @_drawColorHelpForPixel context, x, y, path.fillAssetColor, palette, pixel, renderOptions
              break
          
        else
          # Erase dots at empty pixels.
          @_drawColorHelpForPixel context, x, y, null, null, null, renderOptions
    
    # Explicit return to avoid result collection.
    return
