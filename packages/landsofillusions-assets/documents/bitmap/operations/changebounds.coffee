AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Bitmap.Operations.ChangeBounds extends AM.Document.Versioning.Operation
  @id: -> 'LandsOfIllusions.Assets.Bitmap.Operations.ChangeBounds'
  # bounds: the new bounds for the bitmap or null if not fixed bounds and no pixels are present
  #   left, right, top, bottom: optional extents when setting fixed bounds
  #   fixed: boolean whether all layers should have fixed bounds

  @initialize()
  
  execute: (document) ->
    # If we don't have fixed bounds and we're not asking for
    # them either, raise an error since it's an unnecessary operation.
    unless document.bounds.fixed or @bounds.fixed
      throw new AE.ArgumentException "No changing of bounds is necessary when not using fixed bounds before and after the operation."
      
    # TODO: If we're removing fixed bounds, recalculate dynamic bounds.
    unless @bounds.fixed
      return bounds: true
    
    document.crop @bounds

    # Return that the bounds and potentially layers were changed.
    changes =
      bounds: true
    
    changes.layers = true if document.layers
    changes.layerGroups = true if document.layerGroups
    
    changes
