AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Operations.RemoveLayer extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.Bitmap.Operations.RemoveLayer'
  # layerAddress: array of integers specifying layer group and layer indices of the layer to remove

  @initialize()

  execute: (document) ->
    if @layerAddress.length > 1
      [layerGroupAddress, layerIndex] = @layerAddress

    else
      layerGroupAddress = []
      layerIndex = @layerAddress[0]

    layerGroup = document.getLayerGroup layerGroupAddress
    layerGroup.removeLayer layerIndex

    # Return which fields were changed.
    changedFields = {}
    currentLayerGroupFields = changedFields

    # Build all the layer groups.
    for layerGroupIndex in layerGroupAddress
      changedFields.layerGroups = {}
      changedFields.layerGroups[layerGroupIndex] = {}
      currentLayerGroupFields = changedFields.layerGroups[layerGroupIndex]

    # Indicate that the layers in the final group were changed.
    currentLayerGroupFields.layers = "#{layerIndex}": $unset

    changedFields
