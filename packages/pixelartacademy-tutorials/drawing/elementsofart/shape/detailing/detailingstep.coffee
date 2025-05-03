AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.Detailing.DetailingStep extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.Step
  constructor: ->
    super arguments...
    
    goalPixelsResource = @options.goalPixels
    @goalPixels = goalPixelsResource.pixels()
    
    # We create a map representation for fast retrieval as well.
    @goalPixelsMap = {}
    
    for pixel in @goalPixels
      @goalPixelsMap[pixel.x] ?= {}
      @goalPixelsMap[pixel.x][pixel.y] = pixel.directColor.r is 0
      
  completed: ->
    return unless super arguments...
    
    # We have to make sure this step can first get active and report its pixels so that it can fail due to extra pixels.
    return unless @stepArea.activeStepIndex()?
    
    # Compare goal pixels with first bitmap layer.
    return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        # See if we specify whether a pixel must or must not be here.
        goalPixel = @goalPixelsMap[x]?[y]
        continue unless goalPixel?
        
        # See if this location matches the goal.
        pixel = bitmapLayer.getPixel @stepArea.bounds.x + x, @stepArea.bounds.y + y
        return false if goalPixel isnt pixel?

    true

  hasPixel: (absoluteX, absoluteY) ->
    return unless @isActiveStepInArea()
    
    relativeX = absoluteX - @stepArea.bounds.x
    relativeY = absoluteY - @stepArea.bounds.y

    @goalPixelsMap[relativeX]?[relativeY]?
  
  solve: ->
    bitmap = @tutorialBitmap.bitmap()
    pixels = []
    
    for x in [0...@stepArea.bounds.width] when @goalPixelsMap[x]
      for y in [0...@stepArea.bounds.height] when @goalPixelsMap[x][y]?
        pixel =
          x: x + @stepArea.bounds.x
          y: y + @stepArea.bounds.y

        pixel.paletteColor = {ramp: 0, shade: 0} if @goalPixelsMap[x][y]
        pixels.push pixel
    
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], pixels
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date
  
  drawOverlaidHints: (context, renderOptions = {}) ->
    @_prepareColorHelp context, renderOptions
    
    bitmap = @tutorialBitmap.bitmap()
    palette = @tutorialBitmap.palette()
    
    for x in [0...@stepArea.bounds.width] when @goalPixelsMap[x]
      for y in [0...@stepArea.bounds.height]
        # Do we have a pixel here?
        absoluteX = x + @stepArea.bounds.x
        absoluteY = y + @stepArea.bounds.y
        pixel = bitmap.getPixelForLayerAtAbsoluteCoordinates 0, absoluteX, absoluteY
        goalPixel = @goalPixelsMap[x][y]
        anyPixel = @stepArea.hasGoalPixel absoluteX, absoluteY
        
        if pixel and (goalPixel is false or not anyPixel)
          @_drawColorHelpForPixel context, x, y, null, null, true, renderOptions
          
        # Draw hints on drawn goal pixels and optionally all goal pixels.
        else if goalPixel and not pixel
          @_drawColorHelpForPixel context, x, y, {ramp: 0, shade: 0}, palette, true, renderOptions
    
    # Explicit return to avoid result collection.
    return
