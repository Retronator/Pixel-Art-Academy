AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Operations.UpdateReference extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.VisualAssets.Operations.UpdateReference'
  # index: the index of the reference in the references array
  # changes: object with optional properties that were changed (or undefined for removal)
  #   imageId: id of the reference image
  #   displayed: boolean if the reference is currently displayed
  #   position: data for where to display the reference
  #     x, y: floating point position values
  #   scale: data for how big to display the reference
  #   order: integer value for sorting references
  #   displayMode: where to display the reference (inside the image, over the interface …)
  @initialize()

  execute: (document) ->
    reference = document.references[@index]
    for key, value of @changes
      if value?
        reference[key] = value
        
      else
        delete reference[key]

    # Return that the references were changed.
    references: true
