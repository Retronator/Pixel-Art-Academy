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
        pixel.color = pixel.directColor or palette.color pixel.paletteColor.ramp, pixel.paletteColor.shade
        
      else
        pixel.color = THREE.Color.fromObject pixel.directColor

  completed: ->
    # Compare goal pixels with first bitmap layer.
    return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    palette = @tutorialBitmap.palette()
    
    if backgroundColor = @tutorialBitmap.getBackgroundColor()
      backgroundPixel =
        directColor: backgroundColor
        color: THREE.Color.fromObject backgroundColor

    for x in [0...bitmapLayer.width]
      for y in [0...bitmapLayer.height]
        pixel = bitmapLayer.getPixel(x, y) or backgroundPixel
        goalPixel = @goalPixelsMap[x]?[y] or backgroundPixel
        
        # Both pixels must either exist or not.
        return false unless pixel? is goalPixel?
        
        # Nothing further to check if the pixel is empty.
        continue unless pixel and goalPixel
        
        # If either of the pixels has a direct color, we need to translate the other one too.
        if pixel.paletteColor and goalPixel.paletteColor
          return false unless EJSON.equals pixel.paletteColor, goalPixel.paletteColor
        
        else
          pixelColor = pixel.directColor or palette.color pixel.paletteColor.ramp, pixel.paletteColor.shade
          return false unless goalPixel.color.equals pixelColor

    true

  hasPixel: (x, y) -> @goalPixelsMap[x]?[y]?

  solve: ->
    bitmap = @tutorialBitmap.bitmap()
    pixels = []
    
    for x in [0...bitmap.bounds.width]
      for y in [0...bitmap.bounds.height]
        pixels.push @goalPixelsMap[x]?[y] or {x, y}
    
    # Replace the layer pixels in this bitmap.
    strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], pixels
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date
  
  drawOverlaidHints: (context, renderOptions = {}) ->
    @_preparePixelHintSize renderOptions
    
    bitmap = @tutorialBitmap.bitmap()
    palette = @tutorialBitmap.palette()
    
    for x in [0...@stepArea.bounds.width]
      for y in [0...@stepArea.bounds.height]
        # Do we have a pixel here?
        absoluteX = x + @stepArea.bounds.x
        absoluteY = y + @stepArea.bounds.y
        pixel = bitmap.findPixelAtAbsoluteCoordinates absoluteX, absoluteY
        
        # Do we need a pixel here?
        goalPixel = @goalPixelsMap[x]?[y]
        
        # Clear hints at pixels that should be empty.
        if pixel and not goalPixel
          @_drawPixelHint context, x, y, null
          
        # Draw hints on drawn pixels and optionally all goal pixels.
        else if pixel or goalPixel and @options.drawHintsForGoalPixels
          if goalPixel.paletteColor
            shades = palette.ramps[goalPixel.paletteColor.ramp].shades
            shadeIndex = THREE.Math.clamp goalPixel.paletteColor.shade, 0, shades.length - 1
            color = shades[shadeIndex]
  
          else if goalPixel.directColor
            color = goalPixel.directColor

          @_drawPixelHint context, x, y, color
