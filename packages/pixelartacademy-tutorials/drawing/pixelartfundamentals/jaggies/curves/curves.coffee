AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves extends PAA.Practice.Tutorials.Drawing.Tutorial
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves'

  @fullName: -> "Pixel art curves"

  @initialize()
  
  @assets: -> [
    @SmoothCurves
    @AbruptSegmentLengthChanges
    @StraightParts
    @LineArtCleanup
    @Circles
    @LongCurves
  ]
  
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.DrawingTutorials.PixelArtCurves

  class @FixCurveStep extends TutorialBitmap.PixelsStep
    constructor: ->
      super arguments...
      
      previousPixelsResource = @options.previousPixels
      
      @previousPixels = previousPixelsResource.pixels()
      
      # We create a map representation for fast retrieval as well.
      @previousPixelsMap = {}
      
      for pixel in @previousPixels
        @previousPixelsMap[pixel.x] ?= {}
        @previousPixelsMap[pixel.x][pixel.y] = pixel
      
    drawOverlaidHints: (context, renderOptions = {}) ->
      @_preparePixelHintSize renderOptions

      bitmap = @tutorialBitmap.bitmap()
      palette = @tutorialBitmap.palette()
      
      for x in [0...@stepArea.bounds.width]
        for y in [0...@stepArea.bounds.height]
          # If there is a difference between previous and goal pixels, don't draw the hint.
          previousPixel = @previousPixelsMap[x]?[y]
          goalPixel = @goalPixelsMap[x]?[y]
          continue unless previousPixel? is goalPixel?
          
          # Do we have a pixel here?
          absoluteX = x + @stepArea.bounds.x
          absoluteY = y + @stepArea.bounds.y
          pixel = bitmap.getPixelForLayerAtAbsoluteCoordinates 0, absoluteX, absoluteY
          
          # Do we need a pixel here?
          goalPixel = @goalPixelsMap[x]?[y]
          
          # Clear hints at pixels that should be empty.
          if pixel and not goalPixel
            @_drawPixelHint context, x, y, null
            
          # Draw hints on drawn goal pixels.
          else if goalPixel and not pixel
            @_drawPixelHint context, x, y, palette.ramps[0].shades[0]
      
      # Explicit return to avoid result collection.
      return
