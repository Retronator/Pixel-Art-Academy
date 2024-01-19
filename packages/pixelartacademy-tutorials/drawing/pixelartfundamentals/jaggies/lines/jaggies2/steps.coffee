LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
PAE = PAA.Practice.PixelArtEvaluation
Jaggies2 = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Jaggies2

class Jaggies2.Steps
  class @LineWithoutDoublesStep extends TutorialBitmap.PixelsStep
    constructor: ->
      super arguments...
      
      allowedPixelsResource = @options.allowedPixels
      
      @allowedPixels = allowedPixelsResource.pixels()
      
      # We create a map representation for fast retrieval as well.
      @allowedPixelsMap = {}
      
      for pixel in @allowedPixels
        @allowedPixelsMap[pixel.x] ?= {}
        @allowedPixelsMap[pixel.x][pixel.y] = true

    hasPixel: (x, y) -> @allowedPixelsMap[@stepArea.bounds.x + x]?[@stepArea.bounds.y + y]?

    completed: ->
      return unless super arguments...
      
      # There needs to be a line that goes through all goal pixels.
      return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()
      return unless line = pixelArtEvaluation.getLinesBetween(@goalPixels...)[0]
      
      # The line has to have a thin width (no doubles).
      evaluation = line.evaluate()
      evaluation.widthType is PAE.Line.WidthType.Thin
      
  class @FixStep extends TutorialBitmap.PixelsStep
    constructor: ->
      super arguments...
      
      hintPixelsResource = @options.hintPixels
      
      @hintPixels = hintPixelsResource.pixels()
      
    drawOverlaidHints: (context, renderOptions = {}) ->
      # Draw hints only for the provided pixels.
      @_preparePixelHintSize renderOptions

      @_drawPixelHint context, hintPixel.x, hintPixel.y, hintPixel.directColor for hintPixel in @hintPixels
