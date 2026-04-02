AM = Artificial.Mirage
AS = Artificial.Spectrum
AP = Artificial.Pyramid
PAA = PixelArtAcademy

class PAA.Pages.PixelImageClassification extends AM.Component
  @register 'PixelArtAcademy.Pages.PixelImageClassification'

  @VectorizationAlgorithms:
    Depixelizer: 'Depixelizer'
    PixelArtEvaluation: 'PixelArtEvaluation'

  @sourceSize = 16
  @sourcePreviewScale = 16
  @sourcePreviewMaximumViewportRatio = 0.48

  @initializeDataComponent()

  onCreated: ->
    super arguments...
    
    sourceSize = @constructor.sourceSize

    @isDrawing = new ReactiveField false
    @sourceWidth = new ReactiveField sourceSize
    @sourceHeight = new ReactiveField sourceSize
    @vectorizationAlgorithm = new ReactiveField @constructor.VectorizationAlgorithms.Depixelizer
    @sourceCanvas = new ReactiveField @_createSourceCanvas sourceSize, sourceSize
    @strokePixelValue = null

    @classifiers =
      symbolic: new PAA.ImageClassification.SimpleClassifier.Symbolic
      realistic: new PAA.ImageClassification.SimpleClassifier.Realistic
    
    for classifierName, classifier of @classifiers
      await classifier.createInferenceSession()
    
    inputSize = PAA.ImageClassification.SimpleClassifier.inputSize
    @_classificationInputData = new Float32Array inputSize * inputSize
  
  onRendered: ->
    super arguments...

    @sourcePreviewCanvas = @$('.source.preview-canvas')[0]
    
    inputSize = PAA.ImageClassification.SimpleClassifier.inputSize
    @inputDataPreviewCanvas = new AM.ReadableCanvas inputSize, inputSize
    @inputDataPreviewCanvas.classList.add 'input-data', 'preview-canvas'
    @$('.input-area').append @inputDataPreviewCanvas
    
    @_sourcePreviewMagnification = new ComputedField =>
      return 1 unless sourceCanvas = @sourceCanvas()

      # Keep the editing surface comfortably large while still fitting on screen.
      preferredMagnification = @constructor.sourcePreviewScale
      maximumCanvasWidth = Math.floor window.innerWidth * @constructor.sourcePreviewMaximumViewportRatio
      maximumMagnification = Math.floor maximumCanvasWidth / sourceCanvas.width

      Math.max 1, Math.min preferredMagnification, maximumMagnification

    @autorun (computation) =>
      return unless sourceCanvas = @sourceCanvas()
      @_drawScaledCanvas @sourcePreviewCanvas, sourceCanvas, @_sourcePreviewMagnification(), true

    @_throttledClassify ?= _.throttle =>
      return unless PAA.ImageClassification.SimpleClassifier.convertStrokesToInputData @_strokes, @_classificationInputData
      
      inputDataPreviewImageData = @inputDataPreviewCanvas.getFullImageData()
      inputDataPreviewImageData.data.fill 255
      
      for i in [0...@_classificationInputData.length]
        inputDataPreviewImageData.data[i * 4 + 3] = @_classificationInputData[i]
        
      @inputDataPreviewCanvas.putFullImageData inputDataPreviewImageData
      
      promises = for classifierName, classifier of @classifiers
        do (classifierName, classifier) =>
          new Promise (resolve, reject) =>
            labelProbabilities = await classifier.classify @_classificationInputData
            resolve {classifierName, labelProbabilities}
      
      Promise.all(promises).then (allResults) =>
        html = ""
        for {classifierName, labelProbabilities} in allResults
          filteredProbabilities = _.filter labelProbabilities, (labelProbability) ->
            labelProbability.probability >= 0.01

          classifierTitle = switch classifierName
            when 'symbolic' then 'Symbolic'
            when 'realistic' then 'Realistic'
            else classifierName

          html += "<div class='classifier-results'>"
          html += "<h3>#{classifierTitle}</h3>"
          html += "<ol class='results'>"
          html += (
            for labelProbability in filteredProbabilities[0...10]
              "<li>#{labelProbability.label}: #{Math.round labelProbability.probability * 100}%</li>"
          ).join("")
          html += "</ol>"
          html += "</div>"
        
        @$('.results-area').html html
    ,
      100
      
    @autorun =>
      @_strokes = []
      
      for classifierName, classifier of @classifiers
        return unless classifier.ready()
      
      return unless sourceCanvas = @sourceCanvas()
      
      switch @vectorizationAlgorithm()
        when @constructor.VectorizationAlgorithms.Depixelizer
          splines = AS.PixelArt.Upscaling.Depixelizer.getBSplines sourceCanvas

          for spline in splines
            polygonalChain = spline.getPolygonalChain 6
            @_strokes.push polygonalChain

        when @constructor.VectorizationAlgorithms.PixelArtEvaluation
          Tracker.nonreactive =>
            bitmap = new LOI.Assets.Bitmap
              bounds:
                fixed: true
                left: 0
                top: 0
                right: sourceCanvas.width - 1
                bottom: sourceCanvas.height - 1
              pixelFormat: new LOI.Assets.Bitmap.PixelFormat 'flags', 'directColor'
               
            bitmap.initialize()
            bitmap.addLayer()
            layer = bitmap.layers[0]
          
            flagsAttribute = layer.attributes[LOI.Assets.Bitmap.Attribute.Ids.Flags]
            directColorAttribute = layer.attributes[LOI.Assets.Bitmap.Attribute.Ids.DirectColor]
            
            directColor = r: 0, g: 0, b: 0
            alpha = 0
            
            imageData = sourceCanvas.getFullImageData()
            
            for x in [0...layer.width]
              continue unless x < imageData.width
        
              for y in [0...layer.height]
                continue unless y < imageData.height
                
                imagePixelIndex = y * imageData.width + x
                imagePixelOffset = imagePixelIndex * 4
                directColor.r = imageData.data[imagePixelOffset] / 255
                directColor.g = imageData.data[imagePixelOffset + 1] / 255
                directColor.b = imageData.data[imagePixelOffset + 2] / 255
                alpha = imageData.data[imagePixelOffset + 3] / 255
                alpha = 0 if directColor.r is 1 and directColor.g is 1 and directColor.b is 1
                
                if alpha
                  flagsAttribute.setPixelFlag x, y, LOI.Assets.Bitmap.Attribute.DirectColor.flagValue
                  directColorAttribute.setPixel x, y, directColor
            
            PAE = PAA.Practice.PixelArtEvaluation
            pixelArtEvaluation = new PAE bitmap,
              preserveNoisyFeatures: true
            
            for layer in pixelArtEvaluation.layers
              # Convert lines into polygonal chains.
              for line in layer.lines
                vertices = []
                
                for part in line.parts
                  if part instanceof PAE.Line.Part.StraightLine
                    vertices.push part.displayLine2.start, part.displayLine2.end
                    
                  else if part instanceof PAE.Line.Part.Curve
                    points = part.displayPoints
                    getPoint = (index) => if part.isClosed then points[_.modulo index, points.length] else points[index]
                    
                    vertices.push points[0].position
                    
                    endIndex = if part.isClosed then points.length - 1 else points.length - 2
                    
                    for pointIndex in [0..endIndex]
                      end = getPoint pointIndex + 1
                      vertices.push end.position
                
                @_strokes.push new AP.PolygonalChain vertices
              
              # Convert points into (dummy) polygonal chains.
              for point in layer.points when not point.lines.length
                vertex = new THREE.Vector2 point.pixels[0].x, point.pixels[0].y
                @_strokes.push new AP.PolygonalChain [vertex, vertex]
      
      @_throttledClassify()

    # Stop drag painting even if the pointer is released outside the canvas.
    $(window).on 'mouseup.pixelartacademy-pages-pixelimageclassification', =>
      @strokePixelValue = null
      @isDrawing false

  onDestroyed: ->
    super arguments...

    $(window).off '.pixelartacademy-pages-pixelimageclassification'

  _createSourceCanvas: (sourceWidth, sourceHeight) ->
    targetCanvas = new AM.ReadableCanvas sourceWidth, sourceHeight
    targetImageData = targetCanvas.getFullImageData()

    # Start with a white image so the editable pixels are visible immediately.
    for pixelOffset in [0...targetImageData.data.length] by 4
      targetImageData.data[pixelOffset + offset] = 255 for offset in [0..3]

    if sourceCanvas = @sourceCanvas?()
      sourceImageData = sourceCanvas.getFullImageData()

      # Preserve the overlapping area when the user changes the source dimensions.
      for x in [0...Math.min sourceWidth, sourceCanvas.width]
        for y in [0...Math.min sourceHeight, sourceCanvas.height]
          sourcePixelOffset = (x + y * sourceCanvas.width) * 4
          targetPixelOffset = (x + y * sourceWidth) * 4

          targetImageData.data[targetPixelOffset + offset] = sourceImageData.data[sourcePixelOffset + offset] for offset in [0..3]

    targetCanvas.putFullImageData targetImageData
    targetCanvas

  setSourceSize: (width, height) ->
    width = Math.max 1, Math.round width
    height = Math.max 1, Math.round height

    return if width is @sourceWidth() and height is @sourceHeight()

    @sourceWidth width
    @sourceHeight height
    @sourceCanvas @_createSourceCanvas width, height

  _drawScaledCanvas: (targetCanvas, sourceCanvas, magnification, showPixelGrid = false) ->
    targetCanvas.width = sourceCanvas.width * magnification
    targetCanvas.height = sourceCanvas.height * magnification

    context = targetCanvas.getContext '2d'
    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, targetCanvas.width, targetCanvas.height
    context.imageSmoothingEnabled = false
    context.drawImage sourceCanvas, 0, 0, targetCanvas.width, targetCanvas.height
    @_drawPixelGrid context, targetCanvas, sourceCanvas, magnification if showPixelGrid

  _drawPixelGrid: (context, targetCanvas, sourceCanvas, magnification) ->
    gridOpacity = (magnification - 2) / 100
    gridOpacity = _.clamp gridOpacity, 0, 0.3

    return unless gridOpacity > 0

    context.save()
    context.strokeStyle = "rgba(25,25,25,#{gridOpacity * 2})"
    context.lineWidth = 1
    context.beginPath()

    for y in [0..sourceCanvas.height]
      lineY = y * magnification - 0.5
      context.moveTo 0, lineY
      context.lineTo targetCanvas.width, lineY

    for x in [0..sourceCanvas.width]
      lineX = x * magnification - 0.5
      context.moveTo lineX, 0
      context.lineTo lineX, targetCanvas.height

    context.stroke()
    context.restore()

  events: ->
    super(arguments...).concat
      'mousedown .source': @onMouseDownSource
      'mousemove .source': @onMouseMoveSource
      'mouseleave .source': @onMouseLeaveSource
      'change .source-file-input': @onChangeSourceFileInput
      'click .clear-canvas-button': @onClickClearButton

  onMouseDownSource: (event) ->
    return unless event.which is 1

    pixel = @_getSourcePixelFromEvent event
    return unless pixel

    event.preventDefault()

    @isDrawing true

    # Keep the whole drag either turning pixels on or off based on the first pixel.
    @strokePixelValue = if @_isPixelBlack(pixel.pixelOffset) then 255 else 0
    @_paintSourcePixel pixel.pixelOffset, @strokePixelValue

  onMouseMoveSource: (event) ->
    return unless @strokePixelValue? and event.buttons & 1

    pixel = @_getSourcePixelFromEvent event
    return unless pixel

    @_paintSourcePixel pixel.pixelOffset, @strokePixelValue

  onMouseLeaveSource: (event) ->
    return if event.buttons & 1

    @strokePixelValue = null
    @isDrawing false

  _getSourcePixelFromEvent: (event) ->
    return unless sourceCanvas = @sourceCanvas()

    bounds = event.currentTarget.getBoundingClientRect()
    sourceX = Math.floor (event.clientX - bounds.left) / bounds.width * sourceCanvas.width
    sourceY = Math.floor (event.clientY - bounds.top) / bounds.height * sourceCanvas.height

    return unless 0 <= sourceX < sourceCanvas.width
    return unless 0 <= sourceY < sourceCanvas.height

    pixelOffset: (sourceX + sourceY * sourceCanvas.width) * 4

  _isPixelBlack: (pixelOffset) ->
    return unless sourceCanvas = @sourceCanvas()

    sourceImageData = sourceCanvas.getFullImageData()
    isBlack = true

    for offset in [0..2]
      isBlack &&= sourceImageData.data[pixelOffset + offset] is 0

    isBlack

  _paintSourcePixel: (pixelOffset, value) ->
    return unless sourceCanvas = @sourceCanvas()

    updatedSourceCanvas = new AM.ReadableCanvas sourceCanvas
    updatedImageData = updatedSourceCanvas.getFullImageData()
    pixelAlreadyPainted = true

    for offset in [0..2]
      pixelAlreadyPainted &&= updatedImageData.data[pixelOffset + offset] is value

    return if pixelAlreadyPainted

    updatedImageData.data[pixelOffset + offset] = value for offset in [0..2]
    updatedImageData.data[pixelOffset + 3] = 255
    updatedSourceCanvas.putFullImageData updatedImageData
    @sourceCanvas updatedSourceCanvas

  onChangeSourceFileInput: (event) ->
    file = event.currentTarget.files?[0]
    return unless file

    imageUrl = URL.createObjectURL file
    image = new Image

    image.onload = =>
      @sourceWidth image.width
      @sourceHeight image.height
      @sourceCanvas new AM.ReadableCanvas image

      URL.revokeObjectURL imageUrl
      event.currentTarget.value = null

    image.onerror = =>
      URL.revokeObjectURL imageUrl

    image.src = imageUrl

  onClickClearButton: (event) ->
    @sourceCanvas null
    @sourceCanvas @_createSourceCanvas @sourceWidth(), @sourceHeight()
    @strokePixelValue = null
    @isDrawing false

    @$('.results-area').html ""

  class @SourceWidth extends @DataInputComponent
    @register 'PixelArtAcademy.Pages.PixelImageClassification.SourceWidth'

    constructor: ->
      super arguments...

      @propertyName = 'sourceWidth'
      @type = AM.DataInputComponent.Types.Number
      @realtime = false
      @customAttributes =
        min: 1
        step: 1

    save: (value) ->
      return unless _.isFinite value
      @dataProviderComponent.setSourceSize value, @dataProviderComponent.sourceHeight()

  class @SourceHeight extends @DataInputComponent
    @register 'PixelArtAcademy.Pages.PixelImageClassification.SourceHeight'

    constructor: ->
      super arguments...

      @propertyName = 'sourceHeight'
      @type = AM.DataInputComponent.Types.Number
      @realtime = false
      @customAttributes =
        min: 1
        step: 1

    save: (value) ->
      return unless _.isFinite value
      @dataProviderComponent.setSourceSize @dataProviderComponent.sourceWidth(), value

  class @VectorizationAlgorithm extends @DataInputComponent
    @register 'PixelArtAcademy.Pages.PixelImageClassification.VectorizationAlgorithm'

    constructor: ->
      super arguments...

      @propertyName = 'vectorizationAlgorithm'
      @type = AM.DataInputComponent.Types.Select

    options: ->
      for mode, value of @dataProviderComponent.constructor.VectorizationAlgorithms
        value: value
        name: _.upperFirst _.lowerCase mode
