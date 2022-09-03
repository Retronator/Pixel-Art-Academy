AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Actions.AddLayer extends AM.Document.Versioning.Action
  constructor: (operatorId, bitmap, layerGroupAddress) ->
    super arguments...

    # Forward operation simply adds the layer to the desired layer group.
    forwardOperation = new LOI.Assets.Bitmap.Operations.AddLayer {layerGroupAddress}

    # Going backward, we need to know the layer index the new layer will get.
    layerGroup = bitmap.getLayerGroup layerGroupAddress
    newLayerIndex = layerGroup.layers.length

    backwardOperation = new LOI.Assets.Bitmap.Operations.RemoveLayer
      layerAddress: [layerGroupAddress..., newLayerIndex]

    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation

    @_updateHashCode()
