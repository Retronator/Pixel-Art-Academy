LOI = LandsOfIllusions

class LOI.Assets.Bitmap.LayerGroup
  # name: name of the layer group
  # visible: boolean if the children of this group should be drawn
  # blendMode: name of one of the blend modes
  # layerGroups: array of children groups
  # layers: array of children layers
  
  # This method prepares the provided empty object with nested objects that correspond to layer groups at the specified
  # address and returns the final object that corresponds to the addressed layer group. You can then set which fields
  # have changed on that layer group.
  @prepareOperationChangedFields: (changedFields, layerGroupAddress) ->
    currentLayerGroupChangedFields = changedFields
    
    # Build up the layer group fields.
    for layerGroupIndex in layerGroupAddress
      changedFields.layerGroups = "#{layerGroupIndex}": {}
      currentLayerGroupChangedFields = changedFields.layerGroups[layerGroupIndex]
    
    # Return the fields of the final layer group.
    currentLayerGroupChangedFields
    
  # Returns the changed fields object with the provided layer group changed fields inserted at the specified address.
  @getOperationChangedFields: (layerGroupChangedFields, layerGroupAddress) ->
    changedFields = {}
    layerGroupChangedFieldsTarget = @prepareOperationChangedFields changedFields, layerGroupAddress
    _.assign layerGroupChangedFieldsTarget, layerGroupChangedFields
    changedFields
    
  @initializeLayerGroup: (layerGroup, bitmap) ->
    # Make rich layer objects.
    layerGroup.layers ?= []
    for layer, index in layerGroup.layers
      layerGroup.layers[index] = new LOI.Assets.Bitmap.Layer bitmap, layerGroup, layer

    # Make rich layer group objects.
    layerGroup.layerGroups ?= []
    for subGroup, index in layerGroup.layerGroups
      layerGroup.layerGroups[index] = new LOI.Assets.Bitmap.LayerGroup bitmap, layerGroup, subGroup

  constructor: (@bitmap, @parent, properties) ->
    # Transfer all the properties.
    _.assign @, properties

    @constructor.initializeLayerGroup @, @bitmap

  toPlainObject: ->
    plainObject = _.pick @, ['name', 'visible', 'blendMode']
    plainObject.layerGroups = (layerGroup.toPlainObject() for layerGroup in @layerGroups)
    plainObject.layers = (layer.toPlainObject() for layer in @layers)
    plainObject

  getAddress: ->
    [@parent.getAddress()..., @parent.layerGroups.indexOf @]
  
  prepareOperationChangedFields: (changedFields) ->
    @constructor.prepareOperationChangedFields changedFields, @getAddress()
  
  getOperationChangedFields: (layerGroupChangedFields) ->
    @constructor.getOperationChangedFields layerGroupChangedFields, @getAddress()

  addLayer: ->
    @layers.push new LOI.Assets.Bitmap.Layer @bitmap, @, {}

  removeLayer: (index) ->
    @layers.splice index, 1
