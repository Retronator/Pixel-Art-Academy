PAA = PixelArtAcademy

PAE = PAA.Practice.PixelArtEvaluation

class PAE.Layer
  constructor: (@pixelArtEvaluation, @layerAddress) ->
    @pixels = []
    @pixelsMap = {}
    @cores = []
    @points = []
    @lines = []
    
  getPixel: (x, y) ->
    @pixelsMap[x]?[y]
    
  getPointOn: (pixels...) ->
    for pixel in pixels
      for point in pixel.points
        pointContainsAllPixels = true
        
        for requiredPixel in pixels when requiredPixel not in point.pixels
          pointContainsAllPixels = false
          break
          
        return point if pointContainsAllPixels
    
    null
    
  getLinesAt: (x, y) ->
    return [] unless pixel = @getPixel x, y
    
    pixel.lines
    
  getLinesBetween: (points...) ->
    linesForPoints = for point in points
      @getLinesAt point.x, point.y
      
    _.intersection linesForPoints...
    
  getLinePartsAt: (x, y) ->
    return [] unless pixel = @getPixel x, y
    
    _.flatten(line.getPartsForPixel pixel for line in pixel.lines)
  
  getLinePartsBetween: (points...) ->
    linePartsForPoints = for point in points
      @getLinePartsAt point.x, point.y
    
    _.intersection linePartsForPoints...
    
  mergeCoreInto: (removingCore, enlargingCore) ->
    enlargingCore.mergeCore removingCore
    
    if outline = removingCore.outline
      outlinePoints = _.clone outline.points
    
    @_removeCore removingCore

    if outline
      @_removeLine outline
      @_removePoint point for id, point in outlinePoints when point.lines.length is 0
  
  mergeLineInto: (removingLine, lengtheningLine) ->
    lengtheningLine.mergeLine removingLine
    @_removeLine removingLine
    
  updateArea: (bounds) ->
    # Mark all points as old so we can discern them from new ones during debugging.
    point.old = true for point in @points
    
    # Detect added and removed pixels.
    bounds ?= @pixelArtEvaluation.bitmap.bounds
    
    addedPixels = []
    removedPixels = []
    
    for x in [bounds.x...bounds.x + bounds.width]
      for y in [bounds.y...bounds.y + bounds.height]
        existingPixel = @pixelsMap[x]?[y]
        bitmapPixel = @pixelArtEvaluation.bitmap.getPixelForLayerAtAbsoluteCoordinates @layerAddress, x, y
        
        if bitmapPixel and not existingPixel
          newPixel = @_addPixel x, y
          addedPixels.push newPixel
          
        else if existingPixel and not bitmapPixel
          @_removePixel existingPixel
          removedPixels.push existingPixel
          
    # Removed pixels and neighbors of added and removed pixels invalidate lines, points, and cores they were part of.
    invalidatingPixelsMap = new PAE.PixelsMap
    @invalidatedPixelsMap = new PAE.PixelsMap
    
    for pixel in removedPixels
      # Note: For removed pixels we can't use pixel neighborhood because that
      # wouldn't include the removed pixels (since they no longer are on the layer).
      invalidatingPixelsMap.add pixel
      pixel.forEachNeighbor (neighbor) => invalidatingPixelsMap.add neighbor
    
    for pixel in addedPixels
      pixel.forEachPixelInNeighborhood (neighborhoodPixel) => invalidatingPixelsMap.add neighborhoodPixel
      
    @_invalidateArea invalidatingPixelsMap, @invalidatedPixelsMap, true
    
    # Added pixels are invalidated by default.
    for pixel in addedPixels
      @invalidatedPixelsMap.add pixel
      
    # Removed pixels can't be invalidated.
    for pixel in removedPixels
      @invalidatedPixelsMap.remove pixel
    
    additionalInvalidatingPixelsMap = new PAE.PixelsMap
    
    # Classify core pixels.
    @invalidatedPixelsMap.forEach (pixel) =>
      pixel.classifyCore()
      return unless pixel.couldBeCore()
      
      # Invalidate core pixel and neighbors (since they can fall on the outline).
      pixel.forEachPixelInNeighborhood (neighbor) => additionalInvalidatingPixelsMap.add neighbor
      
    # Assign cores to core pixels.
    @invalidatedPixelsMap.forEach (pixel) =>
      if pixel.isDeepCore and not pixel.core
        core = @_addCore()
        core.fillFromPixel pixel
        
        # Invalidate area of the new core, in case it absorbed any pixels/points outside the current invalidated area.
        for pixel in core.pixels
          pixel.forEachPixelInNeighborhood (neighbor) => additionalInvalidatingPixelsMap.add neighbor
          
    # Invalidate new core areas.
    @_invalidateArea additionalInvalidatingPixelsMap, @invalidatedPixelsMap, false
    
    # Assign pixels to core outline pixels.
    @invalidatedPixelsMap.forEach (pixel) =>
      return if pixel.couldBeCore()
      
      pixel.forEachNeighbor (neighbor) =>
        if neighbor.core and pixel not in neighbor.core.outlinePixels
          # Become the part of the core's outline.
          neighbor.core.assignOutlinePixel pixel
          pixel.assignOutlineCore neighbor.core
    
    # Create core outlines points.
    newPoints = []
    
    for core in @cores
      # Create points on the core outlines.
      for outlinePixel in core.outlinePixels
        point = _.find outlinePixel.points, (point) => point.pixels.length is 1
        
        unless point
          point ?= @_addPoint()
          newPoints.push point
          point.addPixel outlinePixel
    
    # Create double points outside of cores.
    @invalidatedPixelsMap.forEach (pixel) =>
      return if pixel.core
      
      return unless rightNeighbor = @getPixel pixel.x + 1, pixel.y
      return if rightNeighbor.core
      
      return unless bottomNeighbor = @getPixel pixel.x, pixel.y + 1
      return if bottomNeighbor.core
      
      return unless bottomRightNeighbor = @getPixel pixel.x + 1, pixel.y + 1
      return if bottomRightNeighbor.core
      
      return if @getPointOn pixel, rightNeighbor, bottomNeighbor, bottomRightNeighbor
      
      point = @_addPoint()
      newPoints.push point
    
      point.addPixel pointPixel for pointPixel in [pixel, rightNeighbor, bottomNeighbor, bottomRightNeighbor]
      
    # Create single points on all remaining non-core pixels.
    @invalidatedPixelsMap.forEach (pixel) =>
      return if pixel.core or @getPointOn pixel
      
      point = @_addPoint()
      newPoints.push point

      point.addPixel pixel
      
    # Connect points.
    point.connectNeighbors() for point in newPoints
    PAE.Point.optimizeNeighbors newPoints
    
    # Now that we have point connections, finish creating outlines.
    newLines = []

    for core in @cores
      for outlinePixel in core.outlinePixels when not _.find outlinePixel.lines, (line) => line.core is core
        outline = @_addLine()
        newLines.push outline
        
        core.assignOutline outline
        outline.assignCore core
        
        point = _.find outlinePixel.points, (point) -> point.pixels.length is 1
        outline.addOutlinePoints core, point
  
    # Create remaining lines.
    for point in @points
      for neighbor in point.neighbors
        lineFound = false
        
        for line in point.lines
          if neighbor in line.points
            lineFound = true
            break
            
        continue if lineFound
        
        # Ignore lines that connect outlines to double points.
        continue if 1 in [point.radius, neighbor.radius] and (point.getOutlines().length or neighbor.getOutlines().length)
        
        # We need a line going from this point through the neighbor.
        line = @_addLine()
        newLines.push line
        
        line.fillFromPoints point, neighbor
        
    # Filter out lines that don't have any core pixels.
    tooShortLines = []
    
    for line in newLines when line.points.length is 2
      corePoints = 2
      corePoints-- if line.points[0].lines.length > 1
      corePoints-- if line.points[1].lines.length > 1
      continue if corePoints
      
      @_removeLine line
      
    _.pullAll line, tooShortLines
    
    # Classify lines.
    line.classifyLineParts() for line in newLines
    
    # Explicit return to avoid result collection.
    return
    
  _invalidateArea: (invalidatingPixelsMap, invalidatedPixelsMap, invalidateCores) ->
    invalidatedLines = {}
    invalidatedPoints = {}
    invalidatedCores = {}
    
    # Invalidating pixels invalidate their lines, points, and cores.
    invalidatingPixelsMap.forEach (pixel) =>
      invalidatedLines[line.id] = line for line in pixel.lines when invalidateCores or not line.core
      invalidatedPoints[point.id] = point for point in pixel.points
      
      if invalidateCores
        invalidatedCores[pixel.core.id] = pixel.core if pixel.core
        invalidatedCores[outlineCore.id] = outlineCore for outlineCore in pixel.outlineCores
        
    if invalidateCores
      # Invalidated outlines invalidate their cores.
      for id, line of invalidatedLines when line.core
        invalidatedCores[line.core.id] = line.core
  
      # Invalidated cores invalidate their outlines and outline points.
      for id, core of invalidatedCores
        for outline in core.outlines
          invalidatedLines[outline.id] = outline
          
        for pixel in core.outlinePixels
          for point in pixel.points
            invalidatedPoints[point.id] = point for point in pixel.points
          
    # Invalidated points invalidate the lines they are part of. We do this to extend the network of lines getting
    # removed since otherwise the points on the perimeter will not get removed as there are nearby lines connecting to
    # them. Essentially, we want to only leave end points of lines far enough from the changing area to be sure they are
    # not affecting the result.
    for id, point of invalidatedPoints
      invalidatedLines[line.id] = line for line in point.lines
      
    # Invalidated lines invalidate their points.
    for id, line of invalidatedLines
      for point in line.points
        invalidatedPoints[point.id] = point
      
    # Collect invalidated pixels.
    for objects in [invalidatedLines, invalidatedPoints, invalidatedCores]
      for id, object of objects
        for pixel in object.pixels
          invalidatedPixelsMap.add pixel
          
    # Remove invalidated objects.
    @_removeLine line for id, line of invalidatedLines
    @_removePoint point for id, point of invalidatedPoints when point.lines.length is 0
    @_removeCore core for id, core of invalidatedCores
  
  _addPixel: (x, y) ->
    pixel = new PAE.Pixel @, x, y

    @pixels.push pixel
    @pixelsMap[x] ?= {}
    @pixelsMap[x][y] = pixel
    
    pixel
    
  _removePixel: (pixel) ->
    _.pull @pixels, pixel
    @pixelsMap[pixel.x][pixel.y] = null
    
  _addLine: ->
    line = new PAE.Line @
    
    @lines.push line
    
    line
  
  _removeLine: (line) ->
    _.pull @lines, line
    
    line.destroy()
  
  _addPoint: ->
    point = new PAE.Point @
    
    @points.push point
    
    point
  
  _removePoint: (point) ->
    _.pull @points, point
    
    point.destroy()
    
  _addCore: ->
    core = new PAE.Core @
    
    @cores.push core
    
    core
  
  _removeCore: (core) ->
    _.pull @cores, core
    
    core.destroy()
