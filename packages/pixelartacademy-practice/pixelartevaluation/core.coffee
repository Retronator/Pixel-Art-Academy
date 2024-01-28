AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAE.Core
  constructor: (@layer) ->
    @id = Random.id()
    
    @pixels = []
    @outlinePixels = []
    @outlines = []
    
  destroy: ->
    pixel.unassignCore @ for pixel in @pixels
    pixel.unassignOutlineCore @ for pixel in @outlinePixels
    outline.unassignCore @ for outline in @outlines
    
  assignOutlinePixel: (outlinePixel) ->
    throw new AE.ArgumentException "The outline pixel is already assigned to this core.", outlinePixel, @ if outlinePixel in @outlinePixels
    @outlinePixels.push outlinePixel
  
  assignOutline: (outline) ->
    throw new AE.ArgumentException "The outline is already assigned to this core.", outline, @ if outline in @outlines
    @outlines.push outline
    
  unassignOutline: (outline) ->
    throw new AE.ArgumentException "The outline is not assigned to this core.", outline, @ unless outline in @outlines
    _.pull @outlines, outline

  fillFromPixel: (initialPixel) ->
    touchedCores = {}
    fringe = [initialPixel]
    
    while fringe.length
      pixel = fringe.shift()
      @_addPixel pixel
      
      pixel.forEachNeighbor (neighbor) =>
        # Skip our own pixels (which were already added during the fill).
        return if neighbor in @pixels
        
        # Skip surface pixels.
        return unless neighbor.couldBeCore()
        
        # Did we reach another core?
        if neighbor.core
          # Mark the core to be merged.
          touchedCores[neighbor.core.id] = neighbor.core
        
        else
          # The neighbor should be filled.
          fringe.push neighbor unless neighbor in fringe
          
    # Merge any touched cores.
    for id, core of touchedCores
      @layer.mergeCoreInto core, @
  
    # Explicit return to avoid result collection.
    return

  mergeCore: (core) ->
    # Take over all pixels of the core.
    for pixel in _.clone core.pixels
      core._removePixel pixel
      @_addPixel pixel
      
    for pixel in _.clone core.outlinePixels
      core._removeOutlinePixel pixel
      @_addOutlinePixel pixel
  
    # Explicit return to avoid result collection.
    return
  
  _addPixel: (pixel) ->
    @pixels.push pixel
    pixel.assignCore @
    
  _removePixel: (pixel) ->
    _.pull @pixels, pixel
    pixel.unassignCore @
  
  _addOutlinePixel: (pixel) ->
    @outlinePixels.push pixel
    pixel.assignOutlineCore @
  
  _removeOutlinePixel: (pixel) ->
    _.pull @outlinePixels, pixel
    pixel.unassignOutlineCore @
