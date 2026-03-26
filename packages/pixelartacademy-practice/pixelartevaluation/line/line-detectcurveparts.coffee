AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line::_detectCurveParts = ->
  addCurvePart = (startSegmentIndex, endSegmentIndex) =>
    if endSegmentIndex >= startSegmentIndex + @edgeSegments.length
      endSegmentIndex = startSegmentIndex + @edgeSegments.length - 1
      isClosed = true
      
    else
      isClosed = false
      
      # Don't add a curve that is already contained within another part.
      for part in @potentialParts
        return if startSegmentIndex >= part.startSegmentIndex and endSegmentIndex <= part.endSegmentIndex
    
    curve = new PAE.Line.Part.Curve @, startSegmentIndex, endSegmentIndex, null, null, isClosed
    @potentialParts.push curve
    @potentialCurveParts.push curve

    curve
    
  for startSegmentIndex in [0...@edgeSegments.length]
    startEdgeSegment = @edgeSegments[startSegmentIndex]
    edgeSegment = startEdgeSegment
    
    # Start on edge segments that introduce point segments.
    continue unless edgeSegment.pointSegmentsCount
    clockwise = edgeSegment.curveClockwise.after
    endSegmentIndex = startSegmentIndex
    
    # Keep expanding until the turn of direction.
    while clockwise is edgeSegment.curveClockwise.after or not clockwise? or not edgeSegment.curveClockwise.after?
      clockwise ?= edgeSegment.curveClockwise.after

      # Stop if we reached a corner.
      break if edgeSegment.corner.after
      
      # Stop at the end, otherwise continue to next segment.
      break unless edgeSegment = @getEdgeSegment endSegmentIndex + 1
      endSegmentIndex++

      break if edgeSegment is startEdgeSegment
      
    continue unless clockwise?

    curve = addCurvePart startSegmentIndex, endSegmentIndex
    
    # No need to keep going if we found a closed curve.
    break if curve?.isClosed
    
  # Pick the most likely parts for each point.
  potentialCurvePart.calculatePointConfidence() for potentialCurvePart in @potentialCurveParts
  
  for point, pointIndex in @points
    @pointPartIsCurve[pointIndex] = false
    
    for potentialCurvePart in @potentialCurveParts
      if potentialCurvePart.pointConfidences[pointIndex]
        @pointPartIsCurve[pointIndex] = true
        break
