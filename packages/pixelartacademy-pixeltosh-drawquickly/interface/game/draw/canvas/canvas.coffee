AM = Artificial.Mirage
AEc = Artificial.Echo
AP = Artificial.Pyramid
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

Bresenham = require('bresenham-zingl')

class DrawQuickly.Interface.Game.Draw.Canvas extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Interface.Game.Draw.Canvas'
  @register @id()
  
  constructor: ->
    super arguments...
    
    @canDraw = new ReactiveField true
    @drawingStarted = new ReactiveField false
    @strokes = new ReactiveField []
    
    @classificationInputData = new ReactiveField null

  onCreated: ->
    super arguments...
  
  onRendered: ->
    super arguments...

    @canvas = new AM.ReadableCanvas 100, 100
    @canvas.classList.add 'canvas'
    @$('.canvas-area').append @canvas

    @context = @canvas.context

    inputSize = PAA.ImageClassification.SimpleClassifier.inputSize
    _classificationInputData = new Float32Array inputSize * inputSize
    
    @autorun (computation) =>
      strokes = @strokes()
      
      unless strokes.length
        @classificationInputData null
        return
        
      PAA.ImageClassification.SimpleClassifier.convertStrokesToInputData strokes, _classificationInputData
      @classificationInputData _classificationInputData
    
  endDrawing: ->
    @canDraw false
    @_endDraw()
    
  reset: ->
    @clear()
    @canDraw true
    @drawingStarted false
    
  clear: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    
    @strokes []
    
  getPlainStrokes: ->
    for stroke in @strokes()
      for vertex in stroke.vertices
        vertex.toObject()
  
  clearButtonDisabledAttribute: ->
    disabled: true unless @canDraw()
    
  events: ->
    super(arguments...).concat
      'mousedown .canvas-area': @onMouseDownCanvasArea
      'click .clear-button': @onClickClearButton
      
  onMouseDownCanvasArea: (event) ->
    event.preventDefault()
    
    return unless @canDraw()
    
    @drawingStarted true
    
    @_previousX = null
    @_previousY = null
    
    @_stroke = new AP.PolygonalChain []
    
    @_draw event
    
    # Wire movement of the mouse anywhere in the window.
    $(document).on 'pointermove.pixelartacademy-pixeltosh-programs-drawquickly-interface-game-draw-canvas', (event) =>
      @_draw event
    
    # Wire end of dragging on pointer up anywhere in the window.
    $(document).on 'pointerup.pixelartacademy-pixeltosh-programs-drawquickly-interface-game-draw-canvas', =>
      @_endDraw()

  _draw: (event) ->
    rect = @canvas.getBoundingClientRect()
    x = Math.floor (event.clientX - rect.left) / rect.width * @canvas.width
    y = Math.floor (event.clientY - rect.top) / rect.height * @canvas.height
    
    @_stroke.vertices.push new THREE.Vector2 x, y
    
    @_previousX ?= x
    @_previousY ?= y
    
    imageData = @canvas.getFullImageData()
    
    Bresenham.line @_previousX, @_previousY, x, y, (bottomRightX, bottomRightY) =>
      for pixelX in [bottomRightX - 1..bottomRightX] when pixelX >= 0 and pixelX < imageData.width
        for pixelY in [bottomRightY - 1..bottomRightY] when pixelY >= 0 and pixelY < imageData.height
          imageData.data[(pixelX + pixelY * imageData.width) * 4 + 3] = 255
      
      # Explicit return to avoid result collection.
      return
    
    @canvas.putFullImageData imageData
    
    @_previousX = x
    @_previousY = y
    
  _endDraw: ->
    return unless @_stroke
    
    $(document).off '.pixelartacademy-pixeltosh-programs-drawquickly-interface-game-draw-canvas'
  
    strokes = @strokes()
    strokes.push @_stroke.getDecimatedPolygonalChain 1
    @strokes strokes
    
    @_stroke = null
  
  onClickClearButton: (event) ->
    @clear()
