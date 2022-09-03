AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Operations.AddLayer extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.Bitmap.Operations.AddLayer'
  # layerGroupAddress: array of integers specifying layer group indices in which to add the layer

  @initialize()

  execute: (document) ->
    layerGroup = document.getLayerGroup @layerGroupAddress
    newLayerIndex = layerGroup.layers.length
    layerGroup.addLayer()

    # Return which fields were changed.
    changedFields = {}
    currentLayerGroupFields = changedFields

    # Build all the layer groups.
    for layerGroupIndex in @layerGroupAddress
      changedFields.layerGroups = {}
      changedFields.layerGroups[layerGroupIndex] = {}
      currentLayerGroupFields = changedFields.layerGroups[layerGroupIndex]

    # Indicate that the layer was pushed to the layers of the final group.
    currentLayerGroupFields.layers = $push

    changedFields
