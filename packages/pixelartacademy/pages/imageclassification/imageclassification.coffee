AM = Artificial.Mirage
AP = Artificial.Pyramid
PAA = PixelArtAcademy

class PAA.Pages.ImageClassification extends AM.Component
  @register 'PixelArtAcademy.Pages.ImageClassification'

  onCreated: ->
    super arguments...

    @brushSize = new ReactiveField 5
    @isDrawing = new ReactiveField false

    @classifiers = [new @constructor.Classifier.QuickDraw, new @constructor.Classifier.Sketchy]
    
    for classifier in @classifiers
      await classifier.createInferenceSession()
      
    @_strokes = []

  onRendered: ->
    super arguments...

    @canvas = new AM.ReadableCanvas 200, 200
    @canvas.classList.add 'canvas'
    @$('.canvas-area').append @canvas

    @context = @canvas.context
    @context.fillStyle = '#000000'
    
    @$('.canvas-area').append classifier.inputCanvas for classifier in @classifiers

  events: ->
    super(arguments...).concat
      'mousedown .canvas': @onMouseDownCanvas
      'mousemove .canvas': @onMouseMoveCanvas
      'mouseup .canvas': @onMouseUpCanvas
      'mouseleave .canvas': @onMouseLeaveCanvas
      'click .brush-size-button': @onClickBrushSizeButton
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
    @_rawStroke = new AP.PolygonalChain []
    @_smoothStroke = []
    @_strokes.push @_smoothStroke
    
    @_draw event
  
  _draw: (event) ->
    rect = @canvas.getBoundingClientRect()
    x = 0.5 + Math.floor (event.clientX - rect.left) / rect.width * @canvas.width
    y = 0.5 + Math.floor (event.clientY - rect.top) / rect.height * @canvas.height
    
    @_previousX ?= x
    @_previousY ?= y
    
    @_rawStroke.vertices.push new THREE.Vector2 x, y
    
    size = @brushSize()
    
    @context.beginPath()
    @context.lineWidth = size
    @context.lineCap = 'round'
    @context.lineJoin = 'round'
    @context.moveTo @_previousX, @_previousY
    @context.lineTo x, y
    @context.stroke()
    
    @_previousX = x
    @_previousY = y
    
    for classifier in @classifiers
      return unless classifier.ready()
      
    @_throttledClassify ?= _.throttle =>
      @_smoothStroke.splice 0, @_smoothStroke.length, @_rawStroke.getDecimatedPolygonalChain(1).vertices...
      
      promises = for classifier in @classifiers
        do (classifier) =>
          new Promise (resolve, reject) =>
            labelProbabilities = await classifier.classify @_strokes
            resolve labelProbabilities
      
      Promise.all(promises).then (allResults) =>
        html = ""
        for result in allResults
          html += "<ol class='results'>"
          html += (
            for labelProbability in result[0...10]
              "<li>#{labelProbability.label}: #{Math.round labelProbability.probability * 100}%</li>"
          ).join("")
          html += "</ol>"
        
        @$('.results-area').html html
    ,
      100
    
    @_throttledClassify()
    
  _endDraw: ->
    @isDrawing false

  onClickBrushSizeButton: (event) ->
    size = parseInt event.currentTarget.getAttribute 'data-size'
    @brushSize size
  
  onClickClearButton: (event) ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    
    @_strokes = []
    @$('.results-area').html ""
