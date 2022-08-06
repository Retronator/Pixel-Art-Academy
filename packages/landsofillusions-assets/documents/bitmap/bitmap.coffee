AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

Pako = require 'pako'

compressionOptions =
  level: Pako.Z_BEST_COMPRESSION
  
# A 2D raster image asset.
class LOI.Assets.Bitmap extends LOI.Assets.VisualAsset
  @id: -> 'LandsOfIllusions.Assets.Bitmap'
  # layers: array of top-level layers (not contained in any layer group)
  #   name: name of the layer
  #   visible: boolean if this layer should be drawn
  #   blendingMode: one of the layer blending modes
  #   bounds: location of this layer's origin (0,0) in the sprite.
  #     x, y: absolute pixel coordinates of the top-left pixel of this layer
  #     width, height: the size of the layer in pixels
  #   pixelsData: ArrayBuffer with all attributes following each other as defined in the pixel format, not sent to the server
  #   compressedPixelsData: binary object with compressed version of vertices, sent to the server
  #   attributeArrays: map of typed arrays isolating the sections of pixels data, not sent to the server
  # layerGroups: array of groups that hold layers and other groups
  #   name: name of the layer
  #   visible: boolean if the children of this group should be drawn
  #   blendingMode: one of the layer group blending modes
  #   layerGroups: array of children groups
  #   layers: array of children layers
  # pixelFormat: array of attribute IDs, describing the content and order of data in pixelsData
  # bounds: image bounds in pixels (or null if no pixels and not fixed bounds)
  #   left, right, top, bottom
  #   fixed: boolean whether to preserve the set bounds
  @Meta
    name: @id()
  
  @className: 'Bitmap'
  
  @enableVersioning()
  
  constructor: ->
    super arguments...
    
    # Add computed properties to bounds.
    if @bounds
      @bounds.x = @bounds.left
      @bounds.y = @bounds.top
      @bounds.width = @bounds.right - @bounds.left + 1
      @bounds.height = @bounds.bottom - @bounds.top + 1
    
    # Decompress any binary data.
    @_deserialize()
    
  _deserialize: ->
    @_deserializeLayerGroup @
  
  _deserializeLayerGroup: (layerGroup) ->
    if layerGroup.layers
      @_deserializeLayer layer for layer in layerGroup.layers
  
    if layerGroup.layerGroups
      @_deserializeLayerGroup for childGroup in layerGroup.layerGroups
    
  _deserializeLayer: (layer) ->
    layer.pixelsData = Pako.inflateRaw layer.compressedPixelsData
    
    # TODO: Create typed arrays for an easier manipulation of the data.
    layer.attributeArrays = {}
