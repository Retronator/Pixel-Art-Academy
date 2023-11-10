AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Core
  constructor: (@grading) ->
    @id = Random.id()
    
    @pixels = []
    @outline = null
    
  destroy: ->
    pixel.unassignCore @ for pixel in @pixels
    @outline?.unassignCore @
  
  assignOutline: (outline) ->
    throw new AE.ArgumentException "An outline is already assigned to this core.", outline, @ if @outline
    @outline = outline
    
  unassignOutline: (outline) ->
    throw new AE.ArgumentException "The outline is not assigned to this core.", outline, @ unless outline is @outline
    @outline = null

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
      @grading.mergeCoreInto core, @

  mergeCore: (core) ->
    # Take over all pixels of the core.
    for pixel in core.pixels
      core._removePixel pixel
      @_addPixel pixel
  
  _addPixel: (pixel) ->
    @pixels.push pixel
    pixel.assignCore @
    
  _removePixel: (pixel) ->
    _.pull @pixels, pixel
    pixel.unassignCore @
