AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.VisualAsset.Operations.AddReference extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.VisualAssets.Operations.AddReference'
  # reference:
  #   imageId: id of the reference image
  #   displayed: boolean if the reference is currently displayed
  #   position: data for where to display the reference
  #     x, y: floating point position values
  #   scale: data for how big to display the reference
  #   order: integer value for sorting references
  #   displayMode: where to display the reference (inside the image, over the interface …)
  # index: optional index if the reference is to be inserted at a specific position
  @initialize()

  execute: (document) ->
    document.references ?= []
    
    if @index?
      document.references.splice @index, 0, @reference
  
    else
      document.references.push @reference

    # Return that the references were changed.
    references: true
