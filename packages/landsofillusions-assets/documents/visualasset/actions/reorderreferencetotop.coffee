AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Actions.ReorderReferenceToTop extends AM.Document.Versioning.Action
  constructor: (operatorId, asset, imageId) ->
    super arguments...
    
    index = _.findIndex asset.references, (reference) -> reference.image._id is imageId
    throw new AE.ArgumentException "Image is not one of the references." if index is -1
    
    # Find current highest order.
    highestOrder = _.max _.map asset.references, (reference) -> reference.order or 0

    # Forward operation sets the order field.
    forwardOperation = new LOI.Assets.VisualAsset.Operations.UpdateReference
      index: index
      changes:
        order: highestOrder + 1
    
    # Backward operation resets the order field.
    backwardOperation = new LOI.Assets.VisualAsset.Operations.UpdateReference
      index: index
      changes:
        order: asset.references[index].order
    
    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation
    
    @_updateHashCode()
