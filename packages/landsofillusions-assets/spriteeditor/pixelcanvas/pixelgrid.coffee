FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.PixelCanvas.PixelGrid
  constructor: (@pixelCanvas) ->
    @pixelGridData = new ComputedField =>
      @pixelCanvas.interface.getActiveFileData()?.child 'pixelGrid'
      
    @enabledData = new ComputedField =>
      @pixelGridData()?.child 'enabled'
  
    @enabled = new ComputedField =>
      @enabledData()?.value()
  
    @invertColorData = new ComputedField =>
      @pixelGridData()?.child 'invertColor'
  
    @invertColor = new ComputedField =>
      @invertColorData()?.value()
      
  drawToContext: (context) ->
    return unless @enabled()

    camera = @pixelCanvas.camera()

    scale = camera.scale()
    effectiveScale = camera.effectiveScale()
    viewportBounds = camera.viewportBounds

    # Determine grid opacity (scale < 2: 0, scale > 32: 0.3)
    gridOpacity = (scale - 2) / 100
    gridOpacity = THREE.Math.clamp gridOpacity, 0, 0.3

    return unless gridOpacity > 0
  
    if @invertColor()
      context.strokeStyle = "rgba(230,230,230,#{gridOpacity * 3})"
  
    else
      context.strokeStyle = "rgba(25,25,25,#{gridOpacity * 2})"
  
    pixelSize = 1 / effectiveScale
    halfPixelSize = pixelSize / 2
    
    context.lineWidth = pixelSize
    context.translate halfPixelSize, halfPixelSize
    context.beginPath()

    gridBounds =
      left: Math.floor viewportBounds.left()
      top: Math.floor viewportBounds.top()
      right: Math.ceil viewportBounds.right()
      bottom: Math.ceil viewportBounds.bottom()

    for y in [gridBounds.top..gridBounds.bottom]
      pixelPerfectCoordinate = camera.roundCanvasToWindowPixel x: 0, y: y
      context.moveTo gridBounds.left, pixelPerfectCoordinate.y
      context.lineTo gridBounds.right, pixelPerfectCoordinate.y

    for x in [gridBounds.left..gridBounds.right]
      pixelPerfectCoordinate = camera.roundCanvasToWindowPixel x: x, y: 0
      context.moveTo pixelPerfectCoordinate.x, gridBounds.top
      context.lineTo pixelPerfectCoordinate.x, gridBounds.bottom
  
    context.stroke()
    context.translate -halfPixelSize, -halfPixelSize
