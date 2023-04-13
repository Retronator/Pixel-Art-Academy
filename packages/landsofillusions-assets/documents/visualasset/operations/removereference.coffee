AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Operations.RemoveReference extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.VisualAssets.Operations.RemoveReference'
  # index: the index of the reference in the references array
  @initialize()

  execute: (document) ->
    document.references.splice @index, 1

    unless document.references.length
      delete document.references

    # Return that the references were changed.
    references: true
