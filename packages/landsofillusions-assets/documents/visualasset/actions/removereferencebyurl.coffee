AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Actions.RemoveReferenceByUrl extends AM.Document.Versioning.Action
  constructor: (operatorId, asset, url, properties) ->
    super arguments...
    
    reference = _.find asset.references, (reference) => reference.image.url is url
    index = _.indexOf asset.references, reference
  
    # Forward operation removes the reference.
    forwardOperation = new LOI.Assets.VisualAsset.Operations.RemoveReference {index}

    # Backward operation adds the reference.
    backwardOperation = new LOI.Assets.VisualAsset.Operations.AddReference {reference, index}

    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation

    @_updateHashCode()
