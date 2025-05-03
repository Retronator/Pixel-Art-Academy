AE = Artificial.Everywhere
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Tools.AliasedStrokeMask
  constructor: ->
    @_pixelCoordinates = null
    @_pixelCoordinatesLength = 0
  
    @_mask = null
    @_width = 0
    @_height = 0
  
  initialize: (width, height) ->
    return if width is @_width and height is @_height
  
    @_width = width
    @_height = height

    # Create or expand the pixel coordinates array if needed.
    pixelCoordinatesCapacity = (width + height) * 2
    
    unless @_pixelCoordinates and @_pixelCoordinates.length >= pixelCoordinatesCapacity
      @_pixelCoordinates = new Int16Array pixelCoordinatesCapacity

    # Create or expand the mask if needed.
    strokeMaskCapacity = width * height
    
    unless @_mask and @_mask.length >= strokeMaskCapacity
      @_mask = new Uint8Array strokeMaskCapacity
  
  reset: ->
    return unless @_mask
    
    @_pixelCoordinatesLength = 0
    @_mask.fill 0
  
  addPixelCoordinate: (x, y) ->
    return unless @_pixelCoordinates
    
    @_pixelCoordinates[@_pixelCoordinatesLength] = x
    @_pixelCoordinates[@_pixelCoordinatesLength + 1] = y
    @_pixelCoordinatesLength += 2
  
  generate: (cursorArea, bounds) ->
    return unless @_mask
    
    offset = cursorArea.position.centerOffset

    for column, x in cursorArea.aliasedShape
      for value, y in column when value
        for pixelCoordinateIndex in [0...@_pixelCoordinatesLength] by 2
          brushX = @_pixelCoordinates[pixelCoordinateIndex] - offset + x - bounds.left
          brushY = @_pixelCoordinates[pixelCoordinateIndex + 1] - offset + y - bounds.top

          @_mask[brushX + brushY * @_width] = 1 if 0 <= brushX < bounds.width and 0 <= brushY < bounds.height
          
  isPixelInMask: (x, y) ->
    @_mask?[x + y * @_width]
