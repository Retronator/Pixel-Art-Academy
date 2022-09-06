LOI = LandsOfIllusions

# A 2D raster image asset.
class LOI.Assets.Bitmap extends LOI.Assets.VisualAsset
  # Bitmap also needs to inherit layer group methods, but this will be done after LayerGroup is defined.
  @id: -> 'LandsOfIllusions.Assets.Bitmap'
  # layers: array of top-level layers (not contained in any layer group)
  #   name: name of the layer
  #   visible: boolean if this layer should be drawn
  #   blendMode: name of one of the blend modes
  #   bounds: location of this layer's bounds in the sprite.
  #     x, y: absolute pixel coordinates of the top-left pixel of this layer
  #     width, height: the size of the layer in pixels
  #   pixelsData: ArrayBuffer with all attributes following each other as defined in the pixel format, not sent to the server
  #   compressedPixelsData: binary object with compressed version of vertices, sent to the server
  #   attributeArrays: map of typed arrays isolating the sections of pixels data, not sent to the server
  # layerGroups: array of groups that hold layers and other groups
  #   name: name of the layer group
  #   visible: boolean if the children of this group should be drawn
  #   blendMode: name of one of the blend modes
  #   layerGroups: array of children groups
  #   layers: array of children layers
  # pixelFormat: array of attribute Ids, describing the content and order of data in pixelsData
  # bounds: image bounds in pixels (or null if no pixels and not fixed bounds)
  #   left, right, top, bottom
  #   fixed: boolean whether to preserve the set bounds
  @Meta
    name: @id()

  @enableVersioning()

  @className = 'Bitmap'

  @BlendModes =
    PassThrough: 'PassThrough'
    Normal: "Normal"

  initialize: ->
    # Make sure we don't initialize it multiple times.
    if @_initialized
      console.warn "Multiple calls to initialize of bitmap", @
      return

    # Add computed properties to bounds.
    if @bounds
      @bounds.x = @bounds.left
      @bounds.y = @bounds.top
      @bounds.width = @bounds.right - @bounds.left + 1
      @bounds.height = @bounds.bottom - @bounds.top + 1

    # Create rich layer and layer group objects.
    @constructor.LayerGroup.initializeLayerGroup @, @

    @_initialized = true

  toPlainObject: ->
    plainObject = _.assign {}, @
    plainObject.layerGroups = (layerGroup.toPlainObject() for layerGroup in @layerGroups)
    plainObject.layers = (layer.toPlainObject() for layer in @layers)
    plainObject.bounds = _.pick @bounds, ['left', 'top', 'right', 'bottom', 'fixed'] if @bounds
    plainObject

  # Layers

  addLayer: ->
    @layers.push new LOI.Assets.Bitmap.Layer @, @, bounds: @bounds

  removeLayer: (index) ->
    @layers.splice index, 1

  getAddress: -> []
  
  prepareOperationChangedFields: (changedFields) ->
    @constructor.LayerGroup.prepareOperationChangedFields changedFields, @getAddress()
  
  getOperationChangedFields: (layerGroupChangedFields) ->
    @constructor.LayerGroup.getOperationChangedFields layerGroupChangedFields, @getAddress()
    
  getLayerGroup: (layerGroupAddress) ->
    group = @

    for groupIndex in layerGroupAddress
      group = group.layerGroups[groupIndex]

    group

  getLayer: (layerAddress) ->
    if _.isNumber layerAddress
      # Addressing with a number indexes into the top layers.
      return @layers[layerAddress]

    group = @

    for groupIndex, index in layerAddress when index < layerAddress.length - 1
      group = group.layers[groupIndex]

    group.layers[layerAddress[layerAddress.length - 1]]

  # Pixel retrieval

  getPixelForLayerAtCoordinates: (layerAddress, x, y) ->
    return unless layer = @getLayer layerAddress
    pixel = layer.getPixel x, y
  
    # If any of the flags are set, the pixel exists.
    if pixel.flags then pixel else null

  getPixelForLayerAtAbsoluteCoordinates: (layerAddress, absoluteX, absoluteY) ->
    return unless layer = @getLayer layerAddress
    x = absoluteX - (layer.bounds?.x or 0)
    y = absoluteY - (layer.bounds?.y or 0)

    @getPixelForLayerAtCoordinates layerIndex, x, y

  findPixelAtAbsoluteCoordinates: (absoluteX, absoluteY, layerGroup = @) ->
    # Go over all layers in the group.
    for layer in layerGroup.layers
      x = absoluteX - (layer.bounds?.x or 0)
      y = absoluteY - (layer.bounds?.y or 0)
      pixel = layer.getPixel x, y
      
      # If any of the flags are set, the pixel exists.
      return pixel if pixel.flags

    # Go over all sub groups.
    for layerGroup in layerGroup.layerGroups
      pixel = @findPixelAtAbsoluteCoordinates absoluteX, absoluteY, layerGroup
      return pixel if pixel

    null
