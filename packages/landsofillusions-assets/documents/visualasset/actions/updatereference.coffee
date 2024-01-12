AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Actions.UpdateReference extends AM.Document.Versioning.Action
  constructor: (operatorId, asset, imageId, changes) ->
    super arguments...
    
    index = _.findIndex asset.references, (reference) -> reference.image._id is imageId
    throw new AE.ArgumentException "Image is not one of the references." if index is -1
    
    # Forward operation sets the fields.
    forwardOperation = new LOI.Assets.VisualAsset.Operations.UpdateReference {index, changes}
    
    # Backward operation resets the fields.
    reverseChanges = {}
    
    for key of changes
      reverseChanges[key] = asset.references[index][key] or null
    
    backwardOperation = new LOI.Assets.VisualAsset.Operations.UpdateReference
      index: index
      changes: reverseChanges
    
    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation
    
    @_updateHashCode()
