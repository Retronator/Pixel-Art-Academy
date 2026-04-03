AM = Artificial.Mirage
AP = Artificial.Pyramid
PAA = PixelArtAcademy

class PAA.Pages.ImageClassification extends AM.Component
  @register 'PixelArtAcademy.Pages.ImageClassification'

  onCreated: ->
    super arguments...

    @isDrawing = new ReactiveField false
    @classificationInputData = new ReactiveField null

    @classifiers =
      symbolic: new PAA.ImageClassification.SimpleClassifier.Symbolic
      realistic: new PAA.ImageClassification.SimpleClassifier.Realistic
    
    for classifierName, classifier of @classifiers
      await classifier.createInferenceSession()
      
    @_strokes = []

  onRendered: ->
    super arguments...

    @canvasSize = 600
    @strokeWidth = 10

    @canvas = new AM.ReadableCanvas @canvasSize, @canvasSize
    @canvas.classList.add 'canvas'
    @$('.canvas-area').append @canvas

    @context = @canvas.context

    inputSize = PAA.ImageClassification.SimpleClassifier.inputSize
    @_classificationInputData = new Float32Array inputSize * inputSize

  events: ->
    super(arguments...).concat
      'mousedown .canvas': @onMouseDownCanvas
      'mousemove .canvas': @onMouseMoveCanvas
      'mouseup .canvas': @onMouseUpCanvas
      'mouseleave .canvas': @onMouseLeaveCanvas
      'click .clear-canvas-button': @onClickClearButton
  
  onMouseDownCanvas: (event) ->
    event.preventDefault()
    
    @_startDraw event
  
  onMouseMoveCanvas: (event) ->
    return unless @isDrawing()
    
    @_draw event
  
  onMouseUpCanvas: (event) ->
    @_endDraw()
  
  onMouseLeaveCanvas: (event) ->
    @_endDraw()
    
  _startDraw: (event) ->
    @isDrawing true
    @_previousX = null
    @_previousY = null
    @_stroke = new AP.PolygonalChain []
    
    @_draw event
  
  _draw: (event) ->
    rect = @canvas.getBoundingClientRect()
    x = 0.5 + Math.floor (event.clientX - rect.left) / rect.width * @canvas.width
    y = 0.5 + Math.floor (event.clientY - rect.top) / rect.height * @canvas.height
    
    @_previousX ?= x
    @_previousY ?= y
    
    @_stroke.vertices.push new THREE.Vector2 x, y
    
    @context.beginPath()
    @context.lineWidth = @strokeWidth
    @context.lineCap = 'round'
    @context.lineJoin = 'round'
    @context.moveTo @_previousX, @_previousY
    @context.lineTo x, y
    @context.stroke()
    
    @_previousX = x
    @_previousY = y
    
    for classifierName, classifier of @classifiers
      return unless classifier.ready()
      
    @_throttledClassify ?= _.throttle =>
      return unless @_strokes.length or @_stroke?.vertices.length

      strokes = @_strokes.slice()
      strokes.push @_stroke.getDecimatedPolygonalChain 1 if @_stroke?.vertices.length
      
      return unless PAA.ImageClassification.SimpleClassifier.convertStrokesToInputData strokes, @_classificationInputData
      
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
    
    @_throttledClassify()
    
  _endDraw: ->
    return unless @_stroke

    @_strokes.push @_stroke.getDecimatedPolygonalChain 1
    @_stroke = null
    @isDrawing false

  onClickClearButton: (event) ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    
    @_strokes = []
    @_stroke = null
    @classificationInputData null
    @$('.results-area').html ""
