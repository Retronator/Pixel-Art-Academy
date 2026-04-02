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
      @drawInputProperty = new ReactiveField null
      
      toggleProperty = (newProperty) =>
        existingProperty = @drawInputProperty()
        
        if newProperty is existingProperty
          @drawInputProperty null
          
        else
          @drawInputProperty newProperty
  
      $(document).on 'keydown', (event) =>
        switch event.which
          when AC.Keys['1'] then toggleProperty 'better'
          when AC.Keys['2'] then toggleProperty 'pixelArtEvaluation'
          when AC.Keys['3'] then toggleProperty 'depixelizer'
      
      inputSize = PAA.ImageClassification.SimpleClassifier.inputSize
      @inputCanvas = new AM.ReadableCanvas inputSize, inputSize
      
      @inputImageData = @inputCanvas.getFullImageData()
      @inputImageData.data.fill 100

  _render: (context, renderOptions) ->
    return unless @constructor.debug
    
    readabilityAnalysis = @options.readabilityAnalysis()
    
    context.save()
    
    bitmapBounds = @options.bitmapBounds()

    if inputProperty = @drawInputProperty()
      for region, regionIndex in readabilityAnalysis.regions when readabilityAnalysis._classificationInputData[regionIndex]
        bounds = region.bounds or bitmapBounds
        
        @_drawInput context, readabilityAnalysis._classificationInputData[regionIndex][inputProperty], bounds
      
    context.restore()

  _drawInput: (context, inputData, bounds) ->
    for i in [0...inputData.length]
      @inputImageData.data[i * 4 + 3] = 50 + inputData[i] / 255 * 150
    
    @inputCanvas.putFullImageData @inputImageData
    
    context.drawImage @inputCanvas, bounds?.x or 0, bounds?.y or 0, bounds?.width or @inputCanvas.width, bounds?.height or @inputCanvas.height
