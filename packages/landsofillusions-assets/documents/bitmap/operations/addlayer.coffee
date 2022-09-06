AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Operations.AddLayer extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.Bitmap.Operations.AddLayer'
  # layerGroupAddress: array of integers specifying layer group indices in which to add the layer

  @initialize()

  execute: (document) ->
    layerGroup = document.getLayerGroup @layerGroupAddress
    layerGroup.addLayer()

    # Return that the layers of the group were changed.
    layerGroup.getOperationChangedFields layers: true
