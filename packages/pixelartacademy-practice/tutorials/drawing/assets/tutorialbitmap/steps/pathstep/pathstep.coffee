AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

if Meteor.isClient
  require 'path-data-polyfill/path-data-polyfill.js'

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.PathStep extends TutorialBitmap.Step
  @debug = false
  
  # Note: We receive pure SVG paths through options since the SVG paths resource can be broken down into multiple steps.
  constructor: ->
    super arguments...
    
    @options.tolerance ?= 0
    
    @paths = for svgPath in @options.svgPaths
      new @constructor.Path @tutorialBitmap, @, svgPath
  
  completed: ->
    return unless super arguments...

    # Check that all paths have their pixels covered. We check all paths instead of
    # quitting early since paths also remember their completed state for drawing hints.
    completed = true
    
    for path in @paths
      completed = false unless path.completed()
    
    completed
  
  hasPixel: (x, y) ->
    for path in @paths
      return true if path.hasPixel x, y
  
    false
  
  solve: ->
    bitmap = @tutorialBitmap.bitmap()
    
    pixels = []
    
    for x in [@stepArea.bounds.x...@stepArea.bounds.x + @stepArea.bounds.width]
      for y in [@stepArea.bounds.y...@stepArea.bounds.y + @stepArea.bounds.height]
        for path in @paths when path.hasPixel x, y
          pixels.push
            x: x
            y: y
            paletteColor:
              ramp: 0
              shade: 0
    
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], pixels
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date
  
  drawUnderlyingHints: (context, renderOptions) ->
    if @constructor.debug
      # Draw the anti-aliased paths for debug purposes.
      context.globalAlpha = 0.5
      context.imageSmoothingEnabled = false
      
      for path in @paths
        context.drawImage path.canvas, 0, 0
      
      context.globalAlpha = 1

    # Set line style.
    pixelSize = 1 / renderOptions.camera.effectiveScale()
    context.lineWidth = pixelSize
    
    pathOpacity = Math.min 1, renderOptions.camera.scale() / 4
    context.strokeStyle = "hsl(0 0% 50% / #{pathOpacity})"
    context.fillStyle = "hsl(0 0% 50%)"
    
    # Draw path to step area.
    context.save()
    halfPixelSize = pixelSize / 2
    context.translate @stepArea.bounds.x + halfPixelSize, @stepArea.bounds.y + halfPixelSize
    
    path.drawUnderlyingHints context, renderOptions for path in @paths

    context.restore()
    
  drawOverlaidHints: (context, renderOptions) ->
    @_preparePixelHintSize renderOptions
    
    # Erase dots at empty pixels.
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        continue if @stepArea.hasGoalPixel @stepArea.bounds.x + x, @stepArea.bounds.y + y
        
        @_drawPixelHint context, x, y, null
    
    # Explicit return to avoid result collection.
    return
