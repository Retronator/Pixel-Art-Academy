AM = Artificial.Mirage
AS = Artificial.Spectrum
AP = Artificial.Pyramid
PAA = PixelArtAcademy

class PAA.Pages.PixelImageClassification extends AM.Component
  @register 'PixelArtAcademy.Pages.PixelImageClassification'

  @sourceSize = 16
  @sourcePreviewScale = 16
  @sourcePreviewMaximumViewportRatio = 0.48

  @curvesPreviewScale = 8

  onCreated: ->
    super arguments...
    
    sourceSize = @constructor.sourceSize

    @isDrawing = new ReactiveField false
    @sourceCanvas = new ReactiveField @_createSourceCanvas sourceSize, sourceSize
    @strokePixelValue = null

    @curves = new ComputedField =>
      return unless sourceCanvas = @sourceCanvas()

      AS.PixelArt.Upscaling.Depixelizer.getBezierCurves sourceCanvas

    @classifiers =
      symbolic: new PAA.ImageClassification.SimpleClassifier.Symbolic
      realistic: new PAA.ImageClassification.SimpleClassifier.Realistic
    
    for classifierName, classifier of @classifiers
      await classifier.createInferenceSession()
    
    @_strokes = []
    
    inputSize = PAA.ImageClassification.SimpleClassifier.inputSize
    @_classificationInputData = new Float32Array inputSize * inputSize
    
    @_strokes = []

  onRendered: ->
    super arguments...

    @sourcePreviewCanvas = @$('.source.preview-canvas')[0]
    @curvesPreviewCanvas = @$('.curves.preview-canvas')[0]
    @curvesPreviewContext = @curvesPreviewCanvas.getContext '2d'
    
    sourceSize = @constructor.sourceSize
    previewSize = sourceSize * @constructor.curvesPreviewScale
    @curvesPreviewCanvas.width = previewSize
    @curvesPreviewCanvas.height = previewSize

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
      
    @autorun (computation) =>
      return unless curves = @curves()
      
      sourceSize = @constructor.sourceSize
      scale = @constructor.curvesPreviewScale
      previewSize = sourceSize * scale

      @curvesPreviewContext.clearRect 0, 0, previewSize, previewSize
      @curvesPreviewContext.strokeStyle = 'white'
      @curvesPreviewContext.lineWidth = 2
      
      @curvesPreviewContext.beginPath()
      
      @_strokes = []

      for curve in curves
        @curvesPreviewContext.moveTo curve.points[0].x * scale, curve.points[0].y * scale
        #@curvesPreviewContext.quadraticCurveTo curve.points[1].x * scale, curve.points[1].y * scale, curve.points[2].x * scale, curve.points[2].y * scale
        @curvesPreviewContext.lineTo curve.points[2].x * scale, curve.points[2].y * scale
        
        @_strokes.push new AP.PolygonalChain curve.points

      @curvesPreviewContext.stroke()
      
      for classifierName, classifier of @classifiers
        return unless classifier.ready()
      
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

    targetCanvas.putFullImageData targetImageData
    targetCanvas

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
    # Use the same subtle grid approach as the upscaling editor when pixels are large enough.
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

  onClickClearButton: (event) ->
    size = @constructor.sourceSize

    @sourceCanvas @_createSourceCanvas size, size
    @strokePixelValue = null
    @isDrawing false

    @_strokes = []
    @$('.results-area').html ""
