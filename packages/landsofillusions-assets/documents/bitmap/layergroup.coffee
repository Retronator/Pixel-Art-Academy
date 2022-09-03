LOI = LandsOfIllusions

class LOI.Assets.Bitmap.LayerGroup
  # name: name of the layer group
  # visible: boolean if the children of this group should be drawn
  # blendMode: name of one of the blend modes
  # layerGroups: array of children groups
  # layers: array of children layers

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

  addLayer: ->
    @layers.push new LOI.Assets.Bitmap.Layer @bitmap, @, {}

  removeLayer: (index) ->
    @layers.splice index, 1
