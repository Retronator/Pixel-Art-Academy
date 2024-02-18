AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line::_createParts = ->
  if @isClosed
    # For closed lines, first determine where the first edge between a curve and a straight line is.
    firstCurveStraightLineEdgePointIndex = null
    
    for pointIndex in [0...@points.length]
      unless @isPointPartCurve(pointIndex) is @isPointPartCurve(pointIndex + 1)
        firstCurveStraightLineEdgePointIndex = pointIndex + 1
        break
        
    # If we didn't find an edge at all it means all parts are the same.
    if firstCurveStraightLineEdgePointIndex is null
      if @isPointPartCurve 0
        # For curves, we can create a closed one.
        @parts.push new PAE.Line.Part.Curve @, 0, @edgeSegments.length - 1, 0, @points.length - 1, true
        return
    
      else
        # Straight polygons can be created from the start forward.
        firstCurveStraightLineEdgePointIndex ?= 0
    
  else
    # For open lines, we can simply start at the beginning since there will not be any wrap around.
    firstCurveStraightLineEdgePointIndex = 0
    
  pointPartIsCurve = null
  startSegmentIndex = null
  startPointIndex = null
  normalizedStartPointIndex = null
  
  segmentIndex = 0
  edgeSegment = @getEdgeSegment 0
  
  startRangePointIndex = firstCurveStraightLineEdgePointIndex
  endRangePointIndex = firstCurveStraightLineEdgePointIndex + @points.length - 1
  
  for pointIndex in [startRangePointIndex..endRangePointIndex]
    normalizedPointIndex = pointIndex % @points.length
    
    while normalizedPointIndex > edgeSegment.endPointIndex or normalizedPointIndex < edgeSegment.startPointIndex
      segmentIndex++
      edgeSegment = @getEdgeSegment segmentIndex
    
    startSegmentIndex ?= segmentIndex
    startPointIndex ?= pointIndex
    normalizedStartPointIndex ?= normalizedPointIndex
    pointPartIsCurve ?= @isPointPartCurve pointIndex
    
    # Keep expanding if we'll be on the same type of a part.
    continue if pointIndex isnt endRangePointIndex and @isPointPartCurve(pointIndex + 1) is pointPartIsCurve
    
    if pointPartIsCurve
      @parts.push new PAE.Line.Part.Curve @, startSegmentIndex, segmentIndex, normalizedStartPointIndex, normalizedPointIndex, false
      
    else
      # Find which straight line parts overlay the segment.
      potentialStraightLineParts = (part for part in @potentialStraightLineParts when part.overlaysPointRange normalizedStartPointIndex, normalizedPointIndex)
      
      potentialStraightLineSegmentRanges = []
      
      # Remove segments that aren't in the straight-line window.
      for part, partIndex in potentialStraightLineParts
        startPointIndex = _.modulo Math.max(part.startPointIndex, normalizedStartPointIndex - 1), @points.length
        endPointIndex = _.modulo Math.min(part.endPointIndex, normalizedPointIndex + 1), @points.length
        
        start = part.startSegmentIndex
        end = part.endSegmentIndex
        
        start++ while not @_edgeSegmentOverlaysPointRange start, startPointIndex, endPointIndex
        end-- while not @_edgeSegmentOverlaysPointRange end, startPointIndex, endPointIndex
        
        potentialStraightLineSegmentRanges.push {start, end}
      
      # Remove lines that are included in other lines.
      segmentRangeIndex = 0
      
      while segmentRangeIndex < potentialStraightLineSegmentRanges.length
        start = potentialStraightLineSegmentRanges[segmentRangeIndex].start
        end = potentialStraightLineSegmentRanges[segmentRangeIndex].end
        
        remove = false
        for segmentRange, otherSegmentRangeIndex in potentialStraightLineSegmentRanges when otherSegmentRangeIndex isnt segmentRangeIndex
          if start >= segmentRange.start and end <= segmentRange.end
            remove = true
            break
            
        if remove
          potentialStraightLineSegmentRanges.splice segmentRangeIndex, 1
          
        else
          segmentRangeIndex++
          
      # Rotate the parts until the first one is the one starting at this starting segment.
      if @isClosed
        normalizedStartSegmentIndex = _.modulo startSegmentIndex, @edgeSegments.length
        
        while potentialStraightLineSegmentRanges[0].end < normalizedStartSegmentIndex
          potentialStraightLineSegmentRanges.push potentialStraightLineSegmentRanges.shift()
          
      for segmentRange in potentialStraightLineSegmentRanges
        @parts.push new PAE.Line.Part.StraightLine @, segmentRange.start, segmentRange.end
      
    startSegmentIndex = null
    startPointIndex = null
    normalizedStartPointIndex = null
    pointPartIsCurve = null
    
  for part, partIndex in @parts
    part.setNeighbors @getPart(partIndex - 1), @getPart(partIndex + 1)
    
PAE.Line::_edgeSegmentOverlaysPointRange = (segmentIndex, startPointIndex, endPointIndex) ->
  segment = @getEdgeSegment segmentIndex
  return false unless segment.pointSegmentsCount

  pointCount = @points.length
  startPointIndex = startPointIndex % pointCount
  endPointIndex = endPointIndex % pointCount
  
  if endPointIndex >= startPointIndex
    startPointIndex <= segment.endPointIndex and endPointIndex >= segment.startPointIndex
  
  else
    startPointIndex <= segment.endPointIndex or endPointIndex >= segment.startPointIndex
