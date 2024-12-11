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
        if part.endPointIndex > part.startPointIndex
          startPointIndex = _.modulo Math.max(part.startPointIndex, normalizedStartPointIndex - 1), @points.length
          
        else
          startPointIndex = _.modulo normalizedStartPointIndex - 1, @points.length

        endPointIndex = _.modulo Math.min(part.endPointIndex, normalizedPointIndex + 1), @points.length
        
        start = part.startSegmentIndex
        end = part.endSegmentIndex
        
        start++ while not @_edgeSegmentOverlaysPointRange start, startPointIndex, endPointIndex
        end-- while not @_edgeSegmentOverlaysPointRange end, startPointIndex, endPointIndex
        
        # Prevent the same segment range to be added twice due to wrap around in closed lines.
        if start >= @edgeSegments.length
          start %= @edgeSegments.length
          end %= @edgeSegments.length
          
        continue if _.find potentialStraightLineSegmentRanges, (segmentRange) => segmentRange.start is start and segmentRange.end is end
        
        potentialStraightLineSegmentRanges.push {start, end}
      
      # Remove lines that are included in other lines.
      segmentRangeIndex = 0
      
      while segmentRangeIndex < potentialStraightLineSegmentRanges.length
        remove = false
        for segmentRange, otherSegmentRangeIndex in potentialStraightLineSegmentRanges when otherSegmentRangeIndex isnt segmentRangeIndex
          if @_segmentRangeIsIncludedInSegmentRange potentialStraightLineSegmentRanges[segmentRangeIndex], segmentRange
            remove = true
            break
            
        if remove
          potentialStraightLineSegmentRanges.splice segmentRangeIndex, 1
          
        else
          segmentRangeIndex++
          
      if @isClosed
        # Rotate the parts until the first one is the earliest one in the sequence.
        lastSegmentRangeEnd = -1
        
        for segmentRange, segmentRangeIndex in potentialStraightLineSegmentRanges
          if segmentRange.start is lastSegmentRangeEnd + 1
            lastSegmentRangeEnd = segmentRange.end
            continue
          
          # We found the gap, so this segment range must be the starting one.
          for shiftIndex in [0...segmentRangeIndex]
            potentialStraightLineSegmentRanges.push potentialStraightLineSegmentRanges.shift()
            
          break
          
      for segmentRange in potentialStraightLineSegmentRanges
        @parts.push new PAE.Line.Part.StraightLine @, segmentRange.start, segmentRange.end
      
    startSegmentIndex = null
    startPointIndex = null
    normalizedStartPointIndex = null
    pointPartIsCurve = null
    
  for part, partIndex in @parts
    part.setNeighbors @getPart(partIndex - 1), @getPart(partIndex + 1)

PAE.Line::_segmentRangeIsIncludedInSegmentRange = (segmentRange, otherSegmentRange) ->
  if @isClosed
    # Split segment ranges into parts that are before and after the wrap around.
    segmentRangeParts = @_wrapSegmentRangeIntoParts segmentRange
    otherSegmentRangeParts = @_wrapSegmentRangeIntoParts otherSegmentRange
    
    # For the segment range to be included in the other segment range, each of its
    # parts need to be included in one of the parts of the other segment range.
    for segmentRangePart in segmentRangeParts
      return false unless _.find otherSegmentRangeParts, (otherSegmentRangePart) => @_normalizedSegmentRangeIsIncludedInSegmentRange segmentRangePart, otherSegmentRangePart
      
    true
  
  else
    @_normalizedSegmentRangeIsIncludedInSegmentRange segmentRange, otherSegmentRange

PAE.Line::_normalizedSegmentRangeIsIncludedInSegmentRange = (segmentRange, otherSegmentRange) ->
    segmentRange.start >= otherSegmentRange.start and segmentRange.end <= otherSegmentRange.end

PAE.Line::_wrapSegmentRangeIntoParts = (segmentRange) ->
  if segmentRange.end >= @edgeSegments.length
    [
      start: segmentRange.start
      end: @edgeSegments.length - 1
    ,
      start: 0
      end: segmentRange.end - @edgeSegments.length
    ]
    
  else
    [segmentRange]
    
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
