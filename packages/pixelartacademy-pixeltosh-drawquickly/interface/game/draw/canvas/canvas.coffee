AM = Artificial.Mirage
AEc = Artificial.Echo
AP = Artificial.Pyramid
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

Bresenham = require('bresenham-zingl')

_normalizationMatrix = new THREE.Matrix3
_scaledVertex = new THREE.Vector2

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

    # Normalize drawing into a 64×64 canvas with the drawing scaled into the 60×60 area.
    inputSize = 64
    targetSize = 60
    
    @_normalizedCanvas = new AM.ReadableCanvas inputSize, inputSize
    @_normalizedContext = @_normalizedCanvas.context
    @_normalizedContext.lineWidth = 2
    @_normalizedContext.strokeStyle = '#000000'
    @_normalizedContext.lineCap = 'round'
    @_normalizedContext.lineJoin = 'round'

    _classificationInputData = new Float32Array inputSize * inputSize
    
    @autorun (computation) =>
      strokes = @strokes()
      
      # Find bounds of the drawn area.
      minX = Number.POSITIVE_INFINITY
      minY = Number.POSITIVE_INFINITY
      maxX = Number.NEGATIVE_INFINITY
      maxY = Number.NEGATIVE_INFINITY
      
      for stroke in strokes
        for vertex in stroke.vertices
          minX = Math.min minX, vertex.x
          minY = Math.min minY, vertex.y
          maxX = Math.max maxX, vertex.x
          maxY = Math.max maxY, vertex.y
      
      # Make sure something was drawn.
      if minX > maxX or minY > maxY
        @classificationInputData null
        return
        
      # Move drawing to origin.
      _normalizationMatrix.makeTranslation -minX, -minY
      
      # Scale to target size.
      sourceWidth = (maxX - minX) or 1
      sourceHeight = (maxY - minY) or 1
      
      targetWidth = if sourceWidth > sourceHeight then targetSize else targetSize * sourceWidth / sourceHeight
      targetHeight = targetWidth / sourceWidth * sourceHeight

      _normalizationMatrix.scale targetWidth / sourceWidth, targetHeight / sourceHeight
      
      # Center in the input area.
      originX = (inputSize - targetWidth) / 2
      originY = (inputSize - targetHeight) / 2
      
      _normalizationMatrix.translate originX, originY
      
      # Redraw the normalized strokes.
      @_normalizedContext.clearRect 0, 0, inputSize, inputSize
      
      for stroke in strokes
        @_normalizedContext.beginPath()
      
        # Move to first point
        _scaledVertex.copy(stroke.vertices[0]).applyMatrix3 _normalizationMatrix
        @_normalizedContext.moveTo _scaledVertex.x, _scaledVertex.y
        
        # Draw lines to remaining points
        for vertex in stroke.vertices
          _scaledVertex.copy(vertex).applyMatrix3 _normalizationMatrix
          @_normalizedContext.lineTo _scaledVertex.x, _scaledVertex.y
        
        @_normalizedContext.stroke()
      
      # Extract alpha channel into the input array for classification.
      normalizedImageData = @_normalizedCanvas.getFullImageData()
      
      for x in [0...inputSize]
        for y in [0...inputSize]
          pixelIndex = y * inputSize + x
          _classificationInputData[pixelIndex] = normalizedImageData.data[pixelIndex * 4 + 3]
      
      @classificationInputData _classificationInputData
    
  endDrawing: ->
    @canDraw false
    @_endDraw()
    
  clear: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    
    @strokes []
    
  getDrawing: ->
    canvas = new AM.ReadableCanvas 50, 50
    imageData = canvas.getFullImageData()
    imageData.data.fill 255

    for stroke in @strokes()
      for vertexIndex in [0...stroke.vertices.length - 1]
        start = stroke.vertices[vertexIndex]
        end = stroke.vertices[vertexIndex + 1]
        
        startX = Math.round start.x / 2
        startY = Math.round start.y / 2
        endX = Math.round end.x / 2
        endY = Math.round end.y / 2
        
        Bresenham.line startX, startY, endX, endY, (x, y) =>
          for channelIndex in [0...3]
            imageData.data[(x + y * imageData.width) * 4 + channelIndex] = 0
    
    canvas.putFullImageData imageData
    canvas.toDataURL()
  
  clearButtonDisabledAttribute: ->
    disabled: true unless @canDraw()
    
  events: ->
    super(arguments...).concat
      'mousedown .canvas': @onMouseDownCanvas
      'click .clear-button': @onClickClearButton
      
  onMouseDownCanvas: (event) ->
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
