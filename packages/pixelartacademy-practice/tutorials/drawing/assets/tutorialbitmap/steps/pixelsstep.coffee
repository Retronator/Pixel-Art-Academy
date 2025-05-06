AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.PixelsStep extends TutorialBitmap.Step
  constructor: ->
    super arguments...
    
    @options.drawHintsForGoalPixels ?= true
    @options.hasPixelsWhenInactive ?= true
    
    goalPixelsResource = @options.goalPixels
    
    @goalPixels = goalPixelsResource.pixels()
    
    # We create a map representation for fast retrieval as well.
    @goalPixelsMap = {}
    palette = @tutorialBitmap.palette()
    
    for pixel in @goalPixels
      @goalPixelsMap[pixel.x] ?= {}
      @goalPixelsMap[pixel.x][pixel.y] = pixel
      
      if pixel.paletteColor
        pixel.color = palette.color pixel.paletteColor.ramp, pixel.paletteColor.shade
        
      else
        pixel.color = THREE.Color.fromObject pixel.directColor
        pixel.paletteColor = palette.exactPaletteColor pixel.directColor

  completed: ->
    return unless super arguments...
    
    # If a step doesn't have pixels when inactive, we have to make sure this step can
    # first get active and report its pixels so that it can fail due to extra pixels.
    return unless @options.hasPixelsWhenInactive or @stepArea.activeStepIndex()?
    
    # Compare goal pixels with first bitmap layer.
    return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    return unless palette = @tutorialBitmap.palette()
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        # See if we require a pixel here.
        continue unless goalPixel = @goalPixelsMap[x]?[y]

        # We do require a pixel here so check if we have it in the bitmap.
        return false unless pixel = bitmapLayer.getPixel @stepArea.bounds.x + x, @stepArea.bounds.y + y
        
        # If either of the pixels has a direct color, we need to translate the other one too.
        if pixel.paletteColor and goalPixel.paletteColor
          return false unless EJSON.equals pixel.paletteColor, goalPixel.paletteColor
        
        else
          pixelColor = pixel.directColor or palette.color pixel.paletteColor.ramp, pixel.paletteColor.shade
          return false unless goalPixel.color.equals pixelColor

    true

  hasPixel: (absoluteX, absoluteY) ->
    return unless @options.hasPixelsWhenInactive or @isActiveStepInArea()
    
    relativeX = absoluteX - @stepArea.bounds.x
    relativeY = absoluteY - @stepArea.bounds.y

    @goalPixelsMap[relativeX]?[relativeY]?
  
  hasCorrectPixelColor: (absoluteX, absoluteY) ->
    relativeX = absoluteX - @stepArea.bounds.x
    relativeY = absoluteY - @stepArea.bounds.y
    
    # We can't determine correct pixel color if there is no goal pixel here.
    return unless goalPixel = @goalPixelsMap[relativeX]?[relativeY]
    
    # We can't determine correct pixel color if there is no pixel here.
    bitmap = @tutorialBitmap.bitmap()
    return unless pixel = bitmap.getPixelForLayerAtAbsoluteCoordinates 0, absoluteX, absoluteY
    
    backgroundColor = @tutorialBitmap.backgroundColor()
    palette = @tutorialBitmap.palette()
    
    LOI.Assets.ColorHelper.areAssetColorsEqual pixel, goalPixel, palette, backgroundColor

  solve: ->
    bitmap = @tutorialBitmap.bitmap()
    pixels = []
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        pixel = _.clone @goalPixelsMap[x]?[y] or {x, y}
        pixel.x += @stepArea.bounds.x
        pixel.y += @stepArea.bounds.y
        pixels.push pixel if @goalPixelsMap[x]?[y] or not @stepArea.hasGoalPixel @stepArea.bounds.x + x, @stepArea.bounds.y + y
    
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], pixels
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date
  
  drawOverlaidHints: (context, renderOptions = {}) ->
    @_prepareColorHelp context, renderOptions
    
    displayColorHelpUpToPixelCoordinates = @tutorialBitmap.hintsEngineComponents.overlaid.displayColorHelpUpToPixelCoordinates()
    displayAllColorErrors = @tutorialBitmap.hintsEngineComponents.overlaid.displayAllColorErrors()
    
    bitmap = @tutorialBitmap.bitmap()
    palette = @tutorialBitmap.palette()
    
    backgroundColor = @tutorialBitmap.backgroundColor()

    drawHintsForGoalPixels = @options.drawHintsForGoalPixels or displayAllColorErrors
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        # Only display help to a certain point.
        continue if displayColorHelpUpToPixelCoordinates and (y > displayColorHelpUpToPixelCoordinates.y or displayColorHelpUpToPixelCoordinates.y is y and x > displayColorHelpUpToPixelCoordinates.x)
      
        # Do we have a pixel here?
        absoluteX = x + @stepArea.bounds.x
        absoluteY = y + @stepArea.bounds.y
        pixel = bitmap.getPixelForLayerAtAbsoluteCoordinates 0, absoluteX, absoluteY
        
        # Make sure the pixel is not the same as the background color, otherwise it's the same as not having it.
        pixel = null if backgroundColor and LOI.Assets.ColorHelper.areAssetColorsEqual pixel, backgroundColor, palette
        
        # Do we need a pixel here?
        goalPixel = @goalPixelsMap[x]?[y]
        
        # Nothing to do if the two pixels are the same.
        continue if LOI.Assets.ColorHelper.areAssetColorsEqual pixel, goalPixel, palette, backgroundColor
        
        # Clear hints at pixels that should be empty.
        anyPixel = @stepArea.hasGoalPixel absoluteX, absoluteY

        if pixel and not anyPixel
          @_drawColorHelpForPixel context, x, y, null, null, true, renderOptions
          
        # Draw hints on drawn goal pixels and optionally all goal pixels.
        else if goalPixel and (pixel or drawHintsForGoalPixels)
          @_drawColorHelpForPixel context, x, y, goalPixel, palette, pixel, renderOptions
    
    # Explicit return to avoid result collection.
    return
