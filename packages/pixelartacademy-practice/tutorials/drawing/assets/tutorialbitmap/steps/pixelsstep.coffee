AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.PixelsStep extends TutorialBitmap.Step
  constructor: ->
    super arguments...
    
    @options.drawHintsForGoalPixels ?= true
    
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

  completed: ->
    return unless super arguments...
    
    # Compare goal pixels with first bitmap layer.
    return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    return unless palette = @tutorialBitmap.palette()
    
    if backgroundColor = @tutorialBitmap.getBackgroundColor()
      backgroundPixel =
        directColor: backgroundColor
        color: THREE.Color.fromObject backgroundColor

    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        # See if we require a pixel here.
        continue unless goalPixel = @goalPixelsMap[x]?[y] or backgroundPixel

        # We do require a pixel here so check if we have it in the bitmap.
        return false unless pixel = bitmapLayer.getPixel(@stepArea.bounds.x + x, @stepArea.bounds.y + y) or backgroundPixel
        
        # If either of the pixels has a direct color, we need to translate the other one too.
        if pixel.paletteColor and goalPixel.paletteColor
          return false unless EJSON.equals pixel.paletteColor, goalPixel.paletteColor
        
        else
          pixelColor = pixel.directColor or palette.color pixel.paletteColor.ramp, pixel.paletteColor.shade
          return false unless goalPixel.color.equals pixelColor

    true

  hasPixel: (x, y) -> @goalPixelsMap[@stepArea.bounds.x + x]?[@stepArea.bounds.y + y]?

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
    @_preparePixelHintSize renderOptions
    
    drawMissingPixelsUpTo = @tutorialBitmap.hintsEngineComponents.overlaid.drawMissingPixelsUpTo()
    
    bitmap = @tutorialBitmap.bitmap()
    palette = @tutorialBitmap.palette()
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        # Do we have a pixel here?
        absoluteX = x + @stepArea.bounds.x
        absoluteY = y + @stepArea.bounds.y
        pixel = bitmap.findPixelAtAbsoluteCoordinates absoluteX, absoluteY
        
        # Do we need a pixel here?
        anyPixel = @stepArea.hasGoalPixel x, y
        goalPixel = @goalPixelsMap[x]?[y]
        
        # Clear hints at pixels that should be empty.
        if pixel and not anyPixel
          @_drawPixelHint context, x, y, null
          
        # Draw hints on drawn goal pixels and optionally all goal pixels.
        else if goalPixel and (pixel or @options.drawHintsForGoalPixels)
          continue if drawMissingPixelsUpTo and (y > drawMissingPixelsUpTo.y or drawMissingPixelsUpTo.y is y and x > drawMissingPixelsUpTo.x)
          
          if goalPixel.paletteColor
            shades = palette.ramps[goalPixel.paletteColor.ramp].shades
            shadeIndex = THREE.Math.clamp goalPixel.paletteColor.shade, 0, shades.length - 1
            color = shades[shadeIndex]
  
          else if goalPixel.directColor
            color = goalPixel.directColor

          @_drawPixelHint context, x, y, color
