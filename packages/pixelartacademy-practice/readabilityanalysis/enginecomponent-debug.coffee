AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
PAA = PixelArtAcademy
RA = PAA.Practice.ReadabilityAnalysis

class RA.EngineComponent extends RA.EngineComponent
  @debug = false
  
  constructor: (@options) ->
    super arguments...
    
    if @constructor.debug
      @drawInput = new ReactiveField false
  
      $(document).on 'keydown', (event) =>
        switch event.which
          when AC.Keys['1'] then field = @drawInput
          
        field not field() if field
      
      inputSize = PAA.ImageClassification.SimpleClassifier.inputSize
      @inputCanvas = new AM.ReadableCanvas inputSize, inputSize
      
      @inputImageData = @inputCanvas.getFullImageData()
      @inputImageData.data.fill 100

  _render: (context) ->
    super arguments...
    
    return unless @constructor.debug
    
    readabilityAnalysis = @options.readabilityAnalysis()
    pixelArtEvaluation = readabilityAnalysis.pixelArtEvaluation

    focusedPixel = @options.focusedPixel()
    focusedLines = if focusedPixel then pixelArtEvaluation.getLinesAt focusedPixel.x, focusedPixel.y else []
    focusedPoints = if focusedPixel then pixelArtEvaluation.getPointsAt focusedPixel.x, focusedPixel.y else []
    focusedElements = [focusedLines..., focusedPoints...]
    
    context.save()
    
    bitmapBounds = @options.bitmapBounds()

    if @drawInput()
      for region, regionIndex in readabilityAnalysis.regions when readabilityAnalysis._classificationInputData[regionIndex]
        bounds = region.bounds or bitmapBounds
        
        if focusedElements.length
          strokeIndex = _.findIndex region.strokes, (strokeAnalysis) => strokeAnalysis.element is focusedElements[0]
          @_drawInput context, readabilityAnalysis._classificationInputData[regionIndex][strokeIndex + 1], bounds
          
        else
          @_drawInput context, readabilityAnalysis._classificationInputData[regionIndex][0], bounds
      
    context.restore()

  _drawInput: (context, inputData, bounds) ->
    for i in [0...inputData.length]
      @inputImageData.data[i * 4 + 3] = 50 + inputData[i] / 255 * 150
    
    @inputCanvas.putFullImageData @inputImageData
    
    context.drawImage @inputCanvas, bounds?.x or 0, bounds?.y or 0, bounds?.width or @inputCanvas.width, bounds?.height or @inputCanvas.height
