AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Actions.UpdateProperty extends AM.Document.Versioning.Action
  constructor: (operatorId, asset, property, newValue) ->
    super arguments...
    
    # Create difference operations between the current and new value.
    currentValue = asset.properties[property]
    
    forwardOperation = new LOI.Assets.VisualAsset.Operations.UpdateProperty
      property: property
      changes: _.objectDifference currentValue, newValue
    
    backwardOperation = new LOI.Assets.VisualAsset.Operations.UpdateProperty
      property: property
      changes: _.objectDifference newValue, currentValue
    
    # Update operation arrays and the hash code of the action.
    @forward.push forwardOperation
    @backward.push backwardOperation
    
    @_updateHashCode()
