LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Attribute
  @debug = false

  @Ids =
    Flags: "flags"
    ClusterId: "clusterId"
    MaterialIndex: "materialIndex" # flag value 1
    PaletteColor: "paletteColor" # flag value 2
    DirectColor: "directColor" # flag value 4
    Alpha: "alpha"
    Normal: "normal"
    OperationMask: "operationMask"

  # Flags mask that covers all the color flag values.
  @allColorFlagsMask = 1 | 2 | 4
  
  @colorAttributeIds = [@Ids.MaterialIndex, @Ids.PaletteColor, @Ids.DirectColor]

  # Override to provide information for the specific attribute.
  @id = null
  @arrayClass = null
  @elementsPerPixel = null

  @getClassForId: (attributeId) ->
    unless @_attributeClassesById
      # Build the map of attribute classes for fast access.
      @_attributeClassesById = {}
      for className, id of LOI.Assets.Bitmap.Attribute.Ids
        @_attributeClassesById[id] = LOI.Assets.Bitmap.Attribute[className]

    @_attributeClassesById[attributeId]

  constructor: (@area) ->
    # Create the typed array.
    pixelsCount = @area.width * @area.height
    offset = @area.pixelFormat.getOffsetForAttribute @constructor.id, pixelsCount
    length = pixelsCount * @constructor.elementsPerPixel
    @array = new @constructor.arrayClass @area.pixelsData, offset, length

  getPixel: (x, y) ->
    # Override for attributes that use more than one element per pixel.
    index = @getPixelIndex x, y
    @array[index]

  setPixel: (x, y, value) ->
    # Override for attributes that use more than one element per pixel.
    index = @getPixelIndex(x, y)
    @array[index] = value

  clearPixel: (x, y) ->
    @clearPixelAtIndex @getPixelIndex x, y

  clearPixelAtIndex: (index) ->
    for offset in [0...@constructor.elementsPerPixel]
      @array[index + offset] = 0

  isPixelCleared: (x, y) ->
    @isPixelClearedAtIndex @getPixelIndex x, y

  isPixelClearedAtIndex: (index) ->
    # Pixel is not cleared if any value is not zero.
    for offset in [0...@constructor.elementsPerPixel]
      return false if @array[index + offset]

    true

  getPixelIndex: (x, y) ->
    (x + y * @area.width) * @constructor.elementsPerPixel
