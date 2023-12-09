PAA = PixelArtAcademy

class PAA.Practice.PixelArtGrading
  # score: float between 0 and 1 for the final average score
  # consistentLineWidth:
  #   score: float between 0 and 1 with this criterion evaluation
  # evenDiagonals
  #   score: float between 0 and 1 with this criterion's weighted average
  #   segmentLengths:
  #     score: float between 0 and 1 with this criterion evaluation
  #   endSegments:
  #     score: float between 0 and 1 with this criterion evaluation
  # smoothCurves: objects with different criteria evaluations
  #   score: float between 0 and 1 with this criterion evaluation

  @Criteria =
    ConsistentLineWidth: 'ConsistentLineWidth'
    EvenDiagonals: 'EvenDiagonals'
    SmoothCurves: 'SmoothCurves'

  @Subcriteria =
    EvenDiagonals:
      SegmentLengths: 'SegmentLengths'
      EndSegments: 'EndSegments'
    
  @getLetterGrade = (score) ->
    scoreOutOf10 = score * 10
    
    letterBracket = Math.min 9, Math.floor scoreOutOf10
    letterBracket = 4 if letterBracket < 6
    
    letterGrade = String.fromCharCode(65 + 9 - letterBracket)
    
    if letterBracket > 4
      scoreRemainderOutOf100 = Math.round (scoreOutOf10 - letterBracket) * 10
      
      letterGrade += '-' if scoreRemainderOutOf100 < 3
      letterGrade += '+' if scoreRemainderOutOf100 >= 7
    
    letterGrade
    
  constructor: (@bitmap) ->
    @pixels = []
    @pixelsMap = {}
    @cores = []
    @points = []
    @lines = []
    
    # Initialize by updating the full area of the bitmap.
    @_updateArea()
    
    # Subscribe to changes.
    LOI.Assets.Bitmap.versionedDocuments.operationsExecuted.addHandler @, @onOperationsExecuted

  destroy: ->
    LOI.Assets.Bitmap.versionedDocuments.operationsExecuted.removeHandler @, @onOperationsExecuted
    
  getPixel: (x, y) ->
    @pixelsMap[x]?[y]
    
  getLinesAt: (x, y) ->
    return [] unless pixel = @getPixel x, y
    
    pixel.lines
    
  getLinePartsAt: (x, y) ->
    return [] unless pixel = @getPixel x, y
    
    _.flatten(line.getPartsForPixel pixel for line in pixel.lines)
    
  mergeCoreInto: (removingCore, enlargingCore) ->
    enlargingCore.mergeCore removingCore
    @_removeCore removingCore
    
  _updateArea: (bounds) ->
    # Detect added and removed pixels.
    bounds ?= @bitmap.bounds
    
    addedPixels = []
    removedPixels = []
    
    for x in [bounds.x...bounds.x + bounds.width]
      for y in [bounds.y...bounds.y + bounds.height]
        existingPixel = @pixelsMap[x]?[y]
        bitmapPixel = @bitmap.findPixelAtAbsoluteCoordinates x, y
        
        if bitmapPixel and not existingPixel
          newPixel = @_addPixel x, y
          addedPixels.push newPixel
          
        else if existingPixel and not bitmapPixel
          @_removePixel existingPixel
          removedPixels.push existingPixel
          
    # Removed pixels and neighbors of added and removed pixels invalidate lines, points, and cores they were part of.
    invalidatingPixelsMap = {}
    
    addInvalidatingPixel = (pixel) =>
      return unless pixel
      invalidatingPixelsMap[pixel.x] ?= {}
      invalidatingPixelsMap[pixel.x][pixel.y] = pixel
    
    for pixel in removedPixels
      addInvalidatingPixel pixel
      pixel.forEachNeighbor (neighbor) => addInvalidatingPixel neighbor
    
    for pixel in addedPixels
      pixel.forEachNeighbor (neighbor) => addInvalidatingPixel neighbor
    
    invalidatedLines = {}
    invalidatedPoints = {}
    invalidatedCores = {}
    
    for x, pixels of invalidatingPixelsMap
      for y, pixel of pixels
        invalidatedLines[line.id] = line for line in pixel.lines
        invalidatedPoints[point.id] = point for point in pixel.points
        invalidatedCores[pixel.core.id] = pixel.core if pixel.core
      
    # Invalidated cores invalidate their outlines.
    for id, core of invalidatedCores
      invalidatedLines[core.outline.id] = core.outline
      
    # Invalidated lines invalidate their points.
    for id, line of invalidatedLines
      for point in line.points
        invalidatedPoints[point.id] = point
      
    # Collect invalidated pixels.
    invalidatedPixelsMap = {}
    
    addInvalidatedPixel = (pixel) =>
      invalidatedPixelsMap[pixel.x] ?= {}
      invalidatedPixelsMap[pixel.x][pixel.y] = pixel
    
    for objects in [invalidatedLines, invalidatedPoints, invalidatedCores]
      for id, object of objects
        for pixel in object.pixels
          addInvalidatedPixel pixel unless pixel in removedPixels
          
    # Remove invalidated objects.
    @_removeLine line for id, line of invalidatedLines
    @_removePoint point for id, point of invalidatedPoints when point.lines.length is 0
    @_removeCore core for id, core of invalidatedCores
    
    # Added pixels are invalidated by default.
    addInvalidatedPixel pixel for pixel in addedPixels
    
    # Classify core pixels.
    forEachInvalidatedPixel = (operation) =>
      for x, pixels of invalidatedPixelsMap
        for y, pixel of pixels
          operation pixel
          
    forEachInvalidatedPixel (pixel) =>
      pixel.classifyCore()
      
    # Assign cores to core pixels.
    forEachInvalidatedPixel (pixel) =>
      if pixel.isDeepCore and not pixel.core
        core = @_addCore()
        core.fillFromPixel pixel
        
    # Create core outlines.
    newOutlines = []
    newLines = []
    
    for core in @cores when not core.outline
      outline = @_addLine()
      newOutlines.push outline
      newLines.push outline
      
      core.assignOutline outline
      outline.assignCore core
      
    forEachInvalidatedPixel (pixel) =>
      return if pixel.couldBeCore()
      
      pixel.forEachNeighbor (neighbor) =>
        if neighbor.core
          # Become the part of the core's outline.
          outline = neighbor.core.outline
          outline.addPixel pixel unless pixel in outline.pixels
          
    newPoints = []
    
    for outline in newOutlines
      for pixel in outline.pixels
        point = _.find pixel.points, (point) -> point.pixels.length is 1
        
        unless point
          point ?= @_addPoint()
          newPoints.push point
          point.addPixel pixel

        point.assignLine outline
      
    # Create double points outside of cores.
    forEachInvalidatedPixel (pixel) =>
      return if pixel.core
      
      return unless rightNeighbor = @getPixel pixel.x + 1, pixel.y
      return if rightNeighbor.core
      
      return unless bottomNeighbor = @getPixel pixel.x, pixel.y + 1
      return if bottomNeighbor.core
      
      return unless bottomRightNeighbor = @getPixel pixel.x + 1, pixel.y + 1
      return if bottomRightNeighbor.core
      
      point = @_addPoint()
      newPoints.push point
    
      point.addPixel pointPixel for pointPixel in [pixel, rightNeighbor, bottomNeighbor, bottomRightNeighbor]
      
    # Create single points on all remaining non-core pixels.
    forEachInvalidatedPixel (pixel) =>
      return if pixel.core or pixel.points.length
      
      point = @_addPoint()
      newPoints.push point

      point.addPixel pixel
      
    # Connect points.
    point.connectNeighbors() for point in newPoints
    point.optimizeNeighbors() for point in newPoints
    
    # Now that we have point connections, finish creating outlines by adding their points.
    outline.addOutlinePoints() for outline in newOutlines
  
    # Create remaining lines.
    for point in @points
      for neighbor in point.neighbors
        lineFound = false
        
        for line in point.lines
          if neighbor in line.points
            lineFound = true
            break
            
        continue if lineFound
        
        # We need a line going from this point through the neighbor.
        line = @_addLine()
        newLines.push line
        
        line.fillFromPoints point, neighbor
        
    # Classify lines.
    line.classifyLineParts() for line in newLines
    
  _addPixel: (x, y) ->
    pixel = new @constructor.Pixel @, x, y

    @pixels.push pixel
    @pixelsMap[x] ?= {}
    @pixelsMap[x][y] = pixel
    
    pixel
    
  _removePixel: (pixel) ->
    _.pull @pixels, pixel
    @pixelsMap[pixel.x][pixel.y] = null
    
  _addLine: ->
    line = new @constructor.Line @
    
    @lines.push line
    
    line
  
  _removeLine: (line) ->
    _.pull @lines, line
    
    line.destroy()
  
  _addPoint: ->
    point = new @constructor.Point @
    
    @points.push point
    
    point
  
  _removePoint: (point) ->
    _.pull @points, point
    
    point.destroy()
    
  _addCore: ->
    core = new @constructor.Core @
    
    @cores.push core
    
    core
  
  _removeCore: (core) ->
    _.pull @cores, core
    
    core.destroy()
  
  onOperationsExecuted: (document, operations, changedFields) ->
    return unless document._id is @bitmap._id
    
    @_updateArea operation.bounds for operation in operations when operation instanceof LOI.Assets.Bitmap.Operations.ChangePixels
