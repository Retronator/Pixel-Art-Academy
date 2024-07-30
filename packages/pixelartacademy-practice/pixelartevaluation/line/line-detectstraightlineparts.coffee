AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line::_detectStraightLineParts = ->
  lastStraightLineStartSegmentIndex = null
  lastStraightLineEndSegmentIndex = null
  
  addStraightLinePart = (startSegmentIndex, endSegmentIndex) =>
    # Don't add a straight line that is already contained within the last straight line.
    return if lastStraightLineStartSegmentIndex? and startSegmentIndex >= lastStraightLineStartSegmentIndex and endSegmentIndex <= lastStraightLineEndSegmentIndex
    
    lastStraightLineStartSegmentIndex = startSegmentIndex
    lastStraightLineEndSegmentIndex = endSegmentIndex
    
    straightLine = new PAE.Line.Part.StraightLine @, startSegmentIndex, endSegmentIndex
    @potentialParts.push straightLine
    @potentialStraightLineParts.push straightLine

  for startSegmentIndex in [0...@edgeSegments.length]
    startEdgeSegment = @edgeSegments[startSegmentIndex]
    
    # Start on edge segments that introduce point segments.
    continue unless startEdgeSegment.pointsCount

    sideEdgeClockwise = startEdgeSegment.clockwise.after

    # Straight lines are composed of equally sized segments, but allow for 1 count difference for intermediary lines,
    # so we need two possible main counts. Further, the starting and ending segment can be of any length shorter than
    # the main count.
    mainPointsCount1 = null
    mainPointsCount2 = null

    endSegmentIndex = startSegmentIndex
    
    loop
      edgeSegment = @getEdgeSegment endSegmentIndex

      # Stop if we reached a corner.
      break if edgeSegment.corner.after
      
      # Find a side-step segment.
      break unless nextEdgeSegment = @getEdgeSegment endSegmentIndex + 1
      unless nextEdgeSegment.count is 1
        # If we've started on a side-step segment, we can move on.
        if endSegmentIndex is startSegmentIndex and edgeSegment.count is 1
          endSegmentIndex++
          
          # Pretend as we're starting fresh from the next segment.
          startEdgeSegment = @getEdgeSegment endSegmentIndex
          sideEdgeClockwise = not startEdgeSegment.clockwise.before
          
          break unless startEdgeSegment.clockwise.after is sideEdgeClockwise
          
          continue
        
        # The final segment can be a longer if it's not really a side-step as we were only on 1-length segments so far.
        endSegmentIndex++ if mainPointsCount1 is 1 and nextEdgeSegment.pointsCount is 2
        
        break

      # Prevent diagonal to diagonal segments (most likely 90 degrees on a 45 degree diagonal).
      break unless startEdgeSegment.edge.isAxisAligned or nextEdgeSegment.edge.isAxisAligned

      # See if we have a next segment going into the right direction after this.
      endStraightLine = false
      endStraightLine = true unless secondNextEdgeSegment = @getEdgeSegment endSegmentIndex + 2
      endStraightLine = true unless secondNextEdgeSegment?.edge is startEdgeSegment.edge
      
      if endStraightLine
        # Include the final side-step segment if it provides a point.
        endSegmentIndex++ if nextEdgeSegment.pointSegmentsCount
        
        break
      
      # Determine how long the main (middle) parts of the diagonal are.
      determineExtraCount = false

      unless mainPointsCount1
        # We're determining the initial count.
        if secondNextEdgeSegment.pointsCount > startEdgeSegment.pointsCount
          # The first element is shorter so we can consider it being the ending part.
          mainPointsCount1 = secondNextEdgeSegment.pointsCount
          
        else
          mainPointsCount1 = startEdgeSegment.pointsCount
          determineExtraCount = true
          
      else unless mainPointsCount2
        determineExtraCount = true
        
      else unless secondNextEdgeSegment.pointsCount in [mainPointsCount1, mainPointsCount2]
        endStraightLine = true
        
      if determineExtraCount
        unless secondNextEdgeSegment.pointsCount is mainPointsCount1
          # The extra count can only differ by 1 from main count.
          if Math.abs(mainPointsCount1 - secondNextEdgeSegment.pointsCount) is 1
            mainPointsCount2 = secondNextEdgeSegment.pointsCount
          
          else
            endStraightLine = true
        
      if endStraightLine
        # This segment is too much different than the main segment, but it could be the final part if it's shorter.
        if secondNextEdgeSegment.pointsCount < mainPointsCount1
          # Allow this segment to be the end of the straight line.
          endSegmentIndex += 2
          
        break
      
      endSegmentIndex += 2
      
      break unless secondNextEdgeSegment.clockwise.after is sideEdgeClockwise
      
    addStraightLinePart startSegmentIndex, endSegmentIndex
