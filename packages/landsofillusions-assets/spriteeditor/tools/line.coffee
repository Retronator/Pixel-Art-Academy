AE = Artificial.Everywhere
AC = Artificial.Control
AM = Artificial.Mummification
FM = FataMorgana
LOI = LandsOfIllusions

Bresenham = require('bresenham-zingl')

_currentPixelCoordinates = new THREE.Vector2
_startPixelCoordinates = new THREE.Vector2
_pixelCoordinatesDelta = new THREE.Vector2

_strokeMask = new LOI.Assets.SpriteEditor.Tools.AliasedStrokeMask

class LOI.Assets.SpriteEditor.Tools.Line extends LOI.Assets.SpriteEditor.Tools.Shape
  # fractionalPerfectLines: boolean whether to allow 3:2 and 5:2 lines
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Tools.Line'
  @displayName: -> "Line"
  
  @initialize()
  
  constructor: ->
    super arguments...

    @perfectLineRatio = new ReactiveField null

  onActivated: ->
    super arguments...
    
    # Create stroke mask to match asset bounds.
    @_recreateStrokeMaskAutorun = @autorun (computation) =>
      return unless assetData = @editor()?.assetData()
      _strokeMask.initialize assetData.bounds.width, assetData.bounds.height

  onDeactivated: ->
    super arguments...
    
    @_recreateStrokeMaskAutorun.stop()

  cursorType: -> LOI.Assets.SpriteEditor.PixelCanvas.Cursor.Types.AliasedBrush
  
  infoText: ->
    return unless ratio = @perfectLineRatio()

    "#{ratio[1]}:#{ratio[0]}"

  perfectLine: (start, end, mirrored) ->
    fractional = @data.get 'fractionalPerfectLines'
    
    {pixels, ratio} = @constructor.perfectLine start, end, fractional, mirrored
    
    @perfectLineRatio ratio

    for pixel in pixels
      _strokeMask.addPixelCoordinate pixel.x, pixel.y

  updatePixels: ->
    # Calculate which pixels the tool would fill.
    return unless currentPixelCoordinates = @currentPixelCoordinates()

    _currentPixelCoordinates.copy currentPixelCoordinates
    _startPixelCoordinates.copy @startPixelCoordinates() or _currentPixelCoordinates

    keyboardState = AC.Keyboard.getState()
    _strokeMask.reset()

    if @drawingActive()
      if keyboardState.isKeyDown AC.Keys.shift
        # Draw perfect pixel art line.
        @perfectLine _startPixelCoordinates, _currentPixelCoordinates, keyboardState.isCommandOrControlDown()
      
      else
        if keyboardState.isCommandOrControlDown()
          _pixelCoordinatesDelta.subVectors _startPixelCoordinates, _currentPixelCoordinates
          _startPixelCoordinates.add _pixelCoordinatesDelta
        
        @perfectLineRatio null
  
        # Draw bresenham line from start to current coordinates. To assure consistency
        # between drawing lines from both directions, we always draw from top to bottom.
        if _startPixelCoordinates.y < _currentPixelCoordinates.y
          Bresenham.line _startPixelCoordinates.x, _startPixelCoordinates.y, _currentPixelCoordinates.x, _currentPixelCoordinates.y, (x, y) => _strokeMask.addPixelCoordinate x, y
          
        else
          Bresenham.line _currentPixelCoordinates.x, _currentPixelCoordinates.y, _startPixelCoordinates.x, _startPixelCoordinates.y, (x, y) => _strokeMask.addPixelCoordinate x, y
    
    # Apply the cursor area to the stroke mask.
    cursorArea = @editor().cursor().cursorArea()
    assetData = @editor().assetData()
    
    _strokeMask.generate cursorArea, assetData.bounds
   
    # TODO: Apply symmetry.
    
    # Make sure we have paint at all.
    if @paintHelper.isPaintSet()
      pixels = LOI.Assets.SpriteEditor.Tools.Pencil.createPixelsFromStrokeMask assetData, _strokeMask
      @paintHelper.applyPaintToPixels pixels
      
    else
      pixels = []
    
    @pixels pixels
