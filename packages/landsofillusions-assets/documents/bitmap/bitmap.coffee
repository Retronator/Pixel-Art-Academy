LOI = LandsOfIllusions

# A 2D raster image asset.
class LOI.Assets.Bitmap extends LOI.Assets.VisualAsset
  # Bitmap also needs to inherit layer group methods, but this will be done after LayerGroup is defined.
  @id: -> 'LandsOfIllusions.Assets.Bitmap'
  # layers: array of top-level layers (not contained in any layer group)
  #   name: name of the layer
  #   order: integer defining the sorting order within other top-level layers and groups (higher value appears above lower)
  #   visible: boolean if this layer should be drawn (true by default)
  #   blendMode: name of one of the blend modes
  #   bounds: location of this layer's bounds in the bitmap
  #     x, y: absolute pixel coordinates of the top-left pixel of this layer
  #     width, height: the size of the layer in pixels
  #   pixelsData: ArrayBuffer with all attributes following each other as defined in the pixel format, not sent to the server
  #   compressedPixelsData: binary object with compressed version of vertices, sent to the server
  #   attributes: map of attributes with typed arrays isolating the sections of pixels data, not sent to the server
  # layerGroups: array of top-level groups that hold layers and other groups
  #   name: name of the layer group
  #   order: integer defining the sorting order within other top-level layers and groups (higher value appears above lower)
  #   visible: boolean if the children of this group should be drawn (true by default)
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
  @enableDatabaseContent()

  @className = 'Bitmap'

  @BlendModes =
    PassThrough: 'PassThrough'
    Normal: "Normal"

  @toPlainObject: (bitmap) ->
    bitmap.initialize() unless bitmap._initialized
    
    plainObject = LOI.Assets.VisualAsset.toPlainObject bitmap
    plainObject.layerGroups = (layerGroup.toPlainObject() for layerGroup in bitmap.layerGroups) if bitmap.layourGroups
    plainObject.layers = (layer.toPlainObject() for layer in bitmap.layers) if bitmap.layers
    plainObject.pixelFormat = bitmap.pixelFormat
    plainObject.bounds = _.pick bitmap.bounds, ['left', 'top', 'right', 'bottom', 'fixed'] if bitmap.bounds
    plainObject
    
  initialize: ->
    # Make sure we don't initialize it multiple times.
    if @_initialized
      console.warn "Multiple calls to initialize of bitmap", @
      return

    @updateDerivedBounds()

    # Create rich layer and layer group objects.
    @constructor.LayerGroup.initializeLayerGroup @, @

    @_initialized = true
    
  updateDerivedBounds: ->
    # Add computed properties to bounds.
    if @bounds
      @bounds.x = @bounds.left
      @bounds.y = @bounds.top
      @bounds.width = @bounds.right - @bounds.left + 1
      @bounds.height = @bounds.bottom - @bounds.top + 1

  # Layers

  addLayer: ->
    @layers.push new LOI.Assets.Bitmap.Layer @, @, bounds: @bounds

  removeLayer: (index) ->
    @layers.splice index, 1
    
  crop: (bounds) ->
    _.extend @bounds, bounds
    @updateDerivedBounds()

    @constructor.LayerGroup.crop @, @bounds
    
  clear: ->
    @constructor.LayerGroup.clear @

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
    
    [groupAddress..., layerIndex] = layerAddress

    group = @
    group = group.layers[groupIndex] for groupIndex in groupAddress

    group.layers[layerIndex]

  # Pixel retrieval

  getPixelForLayerAtCoordinates: (layerAddress, x, y) ->
    return unless layer = @getLayer layerAddress
    layer.getPixel x, y

  getPixelForLayerAtAbsoluteCoordinates: (layerAddress, absoluteX, absoluteY) ->
    return unless layer = @getLayer layerAddress
    x = absoluteX - (layer.bounds?.x or 0)
    y = absoluteY - (layer.bounds?.y or 0)

    @getPixelForLayerAtCoordinates layerAddress, x, y

  findPixelAtAbsoluteCoordinates: (absoluteX, absoluteY, layerGroup = @) ->
    # Sort layers and layer groups from high to low order.
    items = _.sortBy [layerGroup.layers..., layerGroup.layerGroups...], 'order'

    for item in items by -1 when item.visible ? true
      if item instanceof @constructor.Layer
        layer = item
        x = absoluteX - (layer.bounds?.x or 0)
        y = absoluteY - (layer.bounds?.y or 0)
        pixel = layer.getPixel x, y
        return pixel if pixel
        
      if item instanceof @constructor.LayerGroup
        layerGroup = item
        pixel = @findPixelAtAbsoluteCoordinates absoluteX, absoluteY, layerGroup
        return pixel if pixel

    null

  # Database content
  
  getPreviewImage: ->
    engineBitmap = new LOI.Assets.Engine.PixelImage.Bitmap
      asset: => @
    
    engineBitmap.getCanvas
      lightDirection: new THREE.Vector3 0, 0, -1
