AE = Artificial.Everywhere
AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

_currentPixelCoordinates = new THREE.Vector2
_startPixelCoordinates = new THREE.Vector2
_pixelCoordinatesDelta = new THREE.Vector2

class LOI.Assets.SpriteEditor.Tools.Rectangle extends LOI.Assets.SpriteEditor.Tools.Shape
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Rectangle'
  @displayName: -> "Rectangle"
  
  @initialize()

  cursorType: -> LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.Pixel

  updatePixels: ->
    # Calculate which pixels the tool would fill.
    return unless currentPixelCoordinates = @currentPixelCoordinates()

    _currentPixelCoordinates.copy currentPixelCoordinates
    _startPixelCoordinates.copy @startPixelCoordinates() or _currentPixelCoordinates

    keyboardState = AC.Keyboard.getState()

    pixels = []
    
    if @drawingActive()
      _pixelCoordinatesDelta.subVectors _currentPixelCoordinates, _startPixelCoordinates

      if keyboardState.isKeyDown AC.Keys.shift
        # Draw a square.
        horizontalDelta = Math.abs _pixelCoordinatesDelta.x
        verticalDelta = Math.abs _pixelCoordinatesDelta.y
        
        if horizontalDelta < verticalDelta
          _pixelCoordinatesDelta.y = Math.sign(_pixelCoordinatesDelta.y) * horizontalDelta
          
        else
          _pixelCoordinatesDelta.x = Math.sign(_pixelCoordinatesDelta.x) * verticalDelta
        
        _currentPixelCoordinates.copy(_startPixelCoordinates).add _pixelCoordinatesDelta
  
      if keyboardState.isCommandOrControlDown()
        _startPixelCoordinates.sub _pixelCoordinatesDelta
        
      # Generate pixels between the start and current coordinates, but make sure we even have valid paint.
      pixels = []
      
      if @paintHelper.isPaintSet()
        assetData = @editor().assetData()
        boundsLeft = assetData.bounds.left
        boundsTop = assetData.bounds.top
        boundsRight = assetData.bounds.left + assetData.bounds.width - 1
        boundsBottom = assetData.bounds.top + assetData.bounds.height - 1
        
        addPixel = (x, y) =>
          return unless boundsLeft <= x <= boundsRight and boundsTop <= y <= boundsBottom
          pixels.push {x, y}
        
        for x in [_startPixelCoordinates.x.._currentPixelCoordinates.x]
          addPixel x, _startPixelCoordinates.y
          addPixel x, _currentPixelCoordinates.y
          
        if Math.abs(_startPixelCoordinates.y - _currentPixelCoordinates.y) > 1
          for y in [_startPixelCoordinates.y.._currentPixelCoordinates.y]
            addPixel _startPixelCoordinates.x, y
            addPixel _currentPixelCoordinates.x, y
          
        @paintHelper.applyPaintToPixels pixels

    @pixels pixels
