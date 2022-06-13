AE = Artificial.Everywhere
LOI = LandsOfIllusions
History = LOI.Assets.MeshEditor.Helpers.History

class History.Action.Pencil extends History.Action
  @actionName: -> 'Pencil'
  @initialize()
  
  generateOperations: (picture, pixels) ->
    # See which pixels would actually get changed with this action.
    changedPixels = []
    
    for pixel in pixels
      # If the pixel isn't there, we're changing it.
      unless picture.pixelExists pixel.x, pixel.y
        changedPixels.push pixel
        continue
      
      # At least one of the properties must be different.
      existingPixel = picture.getMapValuesForPixel pixel.x, pixel.y
      different = false
      
      for property, value of pixel when property not in ['x', 'y']
        existingValue = existingPixel[property]
        
        # The properties can either have different existence or if there is a value, have the value be different.
        if value? isnt existingValue? or value? and not _.isEqual value, existingValue
          different = true
          break
      
      if different
        changedPixels.push pixel
        continue
        
    # There's nothing to do if no pixels would be changed.
    return unless changedPixels.length

    # The forward sequence simply sets changed pixels on the picture.
    @_forwardSequence.push History.Operation.SetPixels.generate picture, changedPixels

    # For the backward sequence we have to see which pixels were already set and which were added new.
    existingPixelsToBeSet = []
    newPixelsToBeCleared = []
    
    for pixel in changedPixels
      if existingPixel = picture.getMapValuesForPixel pixel.x, pixel.y
        existingPixel.x = pixel.x
        existingPixel.y = pixel.y
        existingPixelsToBeSet.push existingPixel
        
      else
        newPixelsToBeCleared.push _.pick pixel, ['x', 'y']
  
    @_backwardSequence.push History.Operation.ClearPixels.generate picture, newPixelsToBeCleared if newPixelsToBeCleared.length
    @_backwardSequence.push History.Operation.SetPixels.generate picture, existingPixelsToBeSet if existingPixelsToBeSet.length
    
    console.log "Generate pencil action operations", @_forwardSequence, @_backwardSequence if LOI.Assets.debug = true
