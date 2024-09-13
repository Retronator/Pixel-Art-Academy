AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

if Meteor.isClient
  require 'path-data-polyfill/path-data-polyfill.js'

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.PathStep extends TutorialBitmap.Step
  @debug = false
  
  @drawUnderlyingHints: (context, renderOptions, stepArea, paths) ->
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

    # Set line style.
    pixelSize = 1 / renderOptions.camera.effectiveScale()
    context.lineWidth = pixelSize
    
    pathOpacity = Math.min 1, renderOptions.camera.scale() / 4
    context.strokeStyle = "hsl(0 0% 50% / #{pathOpacity})"
    context.fillStyle = "hsl(0 0% 50%)"
    
    halfPixelSize = pixelSize / 2
    
    # Draw all the paths' hints.
    context.translate halfPixelSize, halfPixelSize
    path.drawUnderlyingHints context, renderOptions for path in paths

    context.restore()
  
  # Note: We receive pure SVG paths through options since the SVG paths resource can be broken down into multiple steps.
  constructor: ->
    super arguments...
    
    @options.tolerance ?= 0
    
    @paths = for svgPath in @options.svgPaths
      new @constructor.Path @tutorialBitmap, @, svgPath
      
    @_pixelsMap = new Uint8Array @stepArea.bounds.width * @stepArea.bounds.height
    
    width = @stepArea.bounds.width
    height = @stepArea.bounds.height
    
    for x in [0...width]
      for y in [0...height]
        for path in @paths when path.hasPixel x, y
          @_pixelsMap[x + y * width] = 1
  
  completed: ->
    return unless super arguments...

    # Check that all paths have their pixels covered. We check all paths instead of
    # quitting early since paths also remember their completed state for drawing hints.
    completed = true
    
    for path in @paths
      completed = false unless path.completed()
    
    completed
  
  hasPixel: (absoluteX, absoluteY) ->
    relativeX = absoluteX - @stepArea.bounds.x
    relativeY = absoluteY - @stepArea.bounds.y
    
    @_pixelsMap[relativeX + relativeY * @stepArea.bounds.width] is 1
  
  solve: ->
    bitmap = @tutorialBitmap.bitmap()

    pixels = []
    width = @stepArea.bounds.width
    height = @stepArea.bounds.height
    
    for x in [0...width]
      for y in [0...height]
        if @_pixelsMap[x + y * width]
          pixels.push
            x: x + @stepArea.bounds.x
            y: y + @stepArea.bounds.y
            paletteColor:
              ramp: 0
              shade: 0
    
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], pixels
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date
  
  drawUnderlyingHints: (context, renderOptions) ->
    @constructor.drawUnderlyingHints context, renderOptions, @stepArea, @paths
    
  drawOverlaidHints: (context, renderOptions) ->
    @_preparePixelHintSize renderOptions
    
    # Erase dots at empty pixels.
    bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        absoluteX = x + @stepArea.bounds.x
        absoluteY = y + @stepArea.bounds.y
        continue if @stepArea.hasGoalPixel absoluteX, absoluteY
        continue unless bitmapLayer.getPixel absoluteX, absoluteY
        
        @_drawPixelHint context, x, y, null
    
    # Explicit return to avoid result collection.
    return
