AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Operations.UpdateProperty extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.VisualAssets.Operations.UpdateProperty'
  # property: the name of the property being changed
  # changes: a difference object that needs to be applied to the previous property value
  @initialize()

  execute: (document) ->
    _.applyObjectDifference document.properties[@property], @changes

    # Return that the property was changed.
    properties:
      "#{@property}": true
