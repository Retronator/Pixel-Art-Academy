FM = FataMorgana
LOI = LandsOfIllusions

_position = x: 0, y: 0

class LOI.Assets.SpriteEditor.PixelCanvas.PixelGrid
  constructor: (@pixelCanvas) ->
    @pixelGridData = new ComputedField =>
      @pixelCanvas.interface.getActiveFileData()?.child 'pixelGrid'
      
    @enabledData = new ComputedField =>
      @pixelGridData()?.child 'enabled'
  
    @enabled = new ComputedField =>
      @enabledData()?.value()
  
    @invertColorData = new ComputedField =>
      @pixelCanvas.interface.getActiveFileData()?.child 'invertUIColors'
  
    @invertColor = new ComputedField =>
      @invertColorData()?.value()
      
  drawToContext: (context) ->
    return unless @enabled()

    camera = @pixelCanvas.camera()

    scale = camera.scale()
    effectiveScale = camera.effectiveScale()
    viewportBounds = camera.viewportCanvasBounds

    # Determine grid opacity (scale < 2: 0, scale > 32: 0.3)
    gridOpacity = (scale - 2) / 100
    gridOpacity = THREE.Math.clamp gridOpacity, 0, 0.3

    return unless gridOpacity > 0
  
    if @invertColor()
      context.strokeStyle = "rgba(230,230,230,#{gridOpacity * 3})"
  
    else
      context.strokeStyle = "rgba(25,25,25,#{gridOpacity * 2})"
  
    pixelSize = 1 / effectiveScale
    context.lineWidth = pixelSize
    context.beginPath()
    
    bounds = @pixelCanvas.assetData()?.bounds
    
    if bounds?.fixed
      gridBounds =
        left: bounds.left
        top: bounds.top
        right: bounds.right + 1
        bottom: bounds.bottom + 1
      
    else
      gridBounds =
        left: Math.floor viewportBounds.left()
        top: Math.floor viewportBounds.top()
        right: Math.ceil viewportBounds.right()
        bottom: Math.ceil viewportBounds.bottom()

    for y in [gridBounds.top..gridBounds.bottom]
      _position.x = 0
      _position.y = y
      camera.roundCanvasToWindowPixel _position, _position
      context.moveTo gridBounds.left, _position.y
      context.lineTo gridBounds.right, _position.y

    for x in [gridBounds.left..gridBounds.right]
      _position.x = x
      _position.y = 0
      camera.roundCanvasToWindowPixel _position, _position
      context.moveTo _position.x, gridBounds.top
      context.lineTo _position.x, gridBounds.bottom
  
    context.stroke()
