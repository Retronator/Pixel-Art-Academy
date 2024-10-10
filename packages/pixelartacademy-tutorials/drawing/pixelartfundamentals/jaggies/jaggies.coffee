AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking
TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies
  @pixelArtEvaluationClickHereMarkup: ->
    markup = []
    
    arrowBase = InterfaceMarking.arrowBase()
    textBase = InterfaceMarking.textBase()
    
    markup.push
      interface:
        selector: '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelartevaluation'
        delay: 1
        bounds:
          x: -30
          y: -40
          width: 50
          height: 40
        markings: [
          line: _.extend {}, arrowBase,
            points: [
              x: -6, y: -25
            ,
              x: 12, y: -8, bezierControlPoints: [
                x: -6, y: -12
              ,
                x: 12, y: -20
              ]
            ]
          text: _.extend {}, textBase,
            position:
              x: -6, y: -27, origin: Markup.TextOriginPosition.BottomCenter
            value: "click here"
        ]
    
    markup
  
  @pixelArtEvaluationClickHereCriterionMarkup: (criterionSelector) ->
    markupStyle = InterfaceMarking.defaultStyle()
    arrowBase = InterfaceMarking.arrowBase()
    textBase = InterfaceMarking.textBase()
    
    [
      interface:
        selector: ".pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelartevaluation #{criterionSelector}"
        delay: 1
        bounds:
          x: -50
          y: -35
          width: 260
          height: 55
        markings: [
          rectangle:
            strokeStyle: markupStyle
            x: -2.5
            y: 2
            width: 199
            height: 13
          line: _.extend {}, arrowBase,
            points: [
              x: -32, y: -9
            ,
              x: -5, y: 8, bezierControlPoints: [
                x: -32, y: 3
              ,
                x: -15, y: 8
              ]
            ]
          text: _.extend {}, textBase,
            position:
              x: -32, y: -11, origin: Markup.TextOriginPosition.BottomCenter
            value: "click here"
        ]
    ]

  class @FixLineStep extends TutorialBitmap.PixelsStep
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
      @_prepareColorHelp context, renderOptions

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
            @_drawColorHelpForPixel context, x, y, null, null, true, renderOptions
            
          # Draw hints on drawn goal pixels.
          else if goalPixel and not pixel
            @_drawColorHelpForPixel context, x, y, color: palette.ramps[0].shades[0], palette, false, renderOptions
      
      # Explicit return to avoid result collection.
      return
