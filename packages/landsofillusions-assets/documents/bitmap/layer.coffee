LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Layer extends LOI.Assets.Bitmap.Area
  # name: name of the layer
  # visible: boolean if this layer should be drawn
  # blendMode: name of one of the blend modes
  # bounds: location of this layer's origin (0,0) in the sprite.
  #   x, y: absolute pixel coordinates of the top-left pixel of this layer
  #   width, height: the size of the layer in pixels
  # compressedPixelsData: binary object with compressed version of vertices, sent to the server
  
  # This method prepares the provided empty object with nested objects that correspond to layer groups and the layer
  # index at the specified address and returns the final object that corresponds to the addressed layer. You can then
  # set which fields have changed on that layer.
  @prepareOperationChangedFields: (changedFields, layerAddress) ->
    # Make sure we have the layer index.
    throw new AE.ArgumentNullException "Layer index must be specified." if layerAddress.length is 0
  
    # Extract layer group address and layer index.
    [layerGroupAddress..., layerIndex] = layerAddress
  
    layerGroupChangedFields = LOI.Assets.Bitmap.LayerGroup.prepareOperationChangedFields changedFields, layerGroupAddress

    # Create the layers field.
    layerGroupChangedFields.layers = "#{layerIndex}": {}
    
    # Return the fields of the layer.
    layerGroupChangedFields.layers[layerIndex]

  # Returns the changed fields object with the provided layer changed fields inserted at the specified address.
  @getOperationChangedFields: (layerChangedFields, layerAddress) ->
    changedFields = {}
    layerChangedFieldsTarget = @prepareOperationChangedFields changedFields, layerAddress
    _.assign layerChangedFieldsTarget, layerChangedFields
    changedFields
    
  constructor: (bitmap, parent, properties) ->
    super properties.bounds?.width, properties.bounds?.height, bitmap.pixelFormat, properties.compressedPixelsData, true

    # We set ancestors here since we can't use @ in the call to super.
    @bitmap = bitmap
    @parent = parent

    # Transfer provided properties and apply defaults.
    _.defaults @, properties,
      name: "New layer"
      visible: true
      blendMode: LOI.Assets.Bitmap.BlendModes.Normal
      
    # Allow saving just compressed pixels data to the database.
    @compressedPixelsData = toPlainObject: => @getCompressedPixelsData()

  toPlainObject: ->
    plainObject = _.pick @, ['name', 'visible', 'blendMode']
    plainObject.bounds = _.pick @bounds, ['x', 'y', 'width', 'height']
    plainObject.compressedPixelsData = @getCompressedPixelsData()
    plainObject

  getAddress: ->
    [@parent.getAddress()..., @parent.layers.indexOf @]

  prepareOperationChangedFields: (changedFields) ->
    @constructor.prepareOperationChangedFields changedFields, @getAddress()
    
  getOperationChangedFields: (layerChangedFields) ->
    @constructor.getOperationChangedFields layerChangedFields, @getAddress()
