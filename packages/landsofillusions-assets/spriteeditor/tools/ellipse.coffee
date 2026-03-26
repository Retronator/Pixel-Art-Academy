AE = Artificial.Everywhere
AC = Artificial.Control
AS = Artificial.Spectrum
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

Bresenham = require('bresenham-zingl')

_currentPixelCoordinates = new THREE.Vector2
_startPixelCoordinates = new THREE.Vector2
_pixelCoordinatesDelta = new THREE.Vector2

class LOI.Assets.SpriteEditor.Tools.Ellipse extends LOI.Assets.SpriteEditor.Tools.FillableShape
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Ellipse'
  @displayName: -> "Ellipse"
  
  @initialize()

  cursorType: -> LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.Pixel

  updatePixels: ->
    # Calculate which pixels the tool would fill.
    return unless currentPixelCoordinates = @currentPixelCoordinates()

    _currentPixelCoordinates.copy currentPixelCoordinates
    _startPixelCoordinates.copy @startPixelCoordinates() or _currentPixelCoordinates

    keyboardState = AC.Keyboard.getState()

    pixels = []
    
    pushEllipsePixel = (x, y) =>
      pixels.push
        x: x
        # HACK: The Bresenham rectangle implementation returns odd-height ellipses shifted by 0.5 pixels.
        y: Math.floor y
    
    if @drawingActive() and @paintHelper.isPaintSet()
      _pixelCoordinatesDelta.subVectors _currentPixelCoordinates, _startPixelCoordinates

      if keyboardState.isKeyDown AC.Keys.shift
        # Draw a circle. We use our own custom circle shapes for small diameters.
        if keyboardState.isCommandOrControlDown()
          diameter = Math.round _pixelCoordinatesDelta.length() * 2
          
        else
          horizontalDelta = Math.abs _pixelCoordinatesDelta.x
          verticalDelta = Math.abs _pixelCoordinatesDelta.y
          diameter = 1 + Math.min horizontalDelta, verticalDelta

        if perfectDiameter = AS.PixelArt.Circle.perfectDiameters[diameter - 1]
          # We have a custom shape for this diameter.
          shape = AS.PixelArt.Circle.getShape perfectDiameter
          centerSize = shape.length - 1
          
          if keyboardState.isCommandOrControlDown()
            _startPixelCoordinates.subScalar Math.floor  centerSize / 2
            
          else
            _startPixelCoordinates.x -= centerSize if _pixelCoordinatesDelta.x < 0
            _startPixelCoordinates.y -= centerSize if _pixelCoordinatesDelta.y < 0
          
          for column, x in shape
            for value, y in column when value
              # Don't fill inner pixels.
              if 0 < x < centerSize and 0 < y < centerSize
                continue if shape[x - 1][y] and shape[x + 1][y] and shape[x][y - 1] and shape[x][y + 1]
              
              pixels.push
                x: x + _startPixelCoordinates.x
                y: y + _startPixelCoordinates.y
        
        else
          # The diameter is too big for a custom shape, use Bresenham.
          if keyboardState.isCommandOrControlDown()
            # We're drawing from the center out so we can use the circle method.
            radius = Math.round _pixelCoordinatesDelta.length()

            Bresenham.circle _startPixelCoordinates.x, _startPixelCoordinates.y, radius, (x, y) =>
              pixels.push {x, y}
            
          else
            # We're inscribing a circle into a square, so use the ellipse in a rectangle method.
            if horizontalDelta < verticalDelta
              _pixelCoordinatesDelta.y = Math.sign(_pixelCoordinatesDelta.y) * horizontalDelta
            
            else
              _pixelCoordinatesDelta.x = Math.sign(_pixelCoordinatesDelta.x) * verticalDelta
            
            _currentPixelCoordinates.copy(_startPixelCoordinates).add _pixelCoordinatesDelta
            
            Bresenham.ellipseRect _startPixelCoordinates.x, _startPixelCoordinates.y, _currentPixelCoordinates.x, _currentPixelCoordinates.y, pushEllipsePixel
            
      else
        # Draw an ellipse.
        if keyboardState.isCommandOrControlDown()
          _startPixelCoordinates.sub _pixelCoordinatesDelta
          
        Bresenham.ellipseRect _startPixelCoordinates.x, _startPixelCoordinates.y, _currentPixelCoordinates.x, _currentPixelCoordinates.y, pushEllipsePixel
        
      if pixels.length and @data.get 'filled'
        rows = {}
        
        for pixel in pixels
          rows[pixel.y] ?= []
          rows[pixel.y].push pixel.x
          
        for y, xs of rows
          y = parseInt y
          minX = _.min xs
          maxX = _.max xs
          pushEllipsePixel x, y for x in [minX...maxX] when x not in xs
          
      @paintHelper.applyPaintToPixels pixels

    @pixels pixels
