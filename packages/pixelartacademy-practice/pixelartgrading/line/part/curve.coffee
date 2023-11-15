AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Line.Part.Curve extends PAG.Line.Part
  constructor: (..., @isClosed) ->
    super arguments...

    # Create display points.
    @displayPoints = []
    
    segmentParameter = 0.5
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      # Exclude side-step segments from generating curve points, except at end points.
      continue unless segment.hasPointSegment.before or segment.hasPointSegment.on or segment.hasPointSegment.after
      
      startPointIndex = segment.startPointIndex
      endPointIndex = segment.endPointIndex
      
      startPointIndex = Math.max startPointIndex, @startPointIndex if segmentIndex is @startSegmentIndex
      endPointIndex = Math.min endPointIndex, @endPointIndex if segmentIndex is @endSegmentIndex
      
      startPoint = @line.getPoint startPointIndex
      endPoint = @line.getPoint endPointIndex
      
      unless @isClosed
        segmentParameter = switch segmentIndex
          when @startSegmentIndex then 0
          when @endSegmentIndex then 1
          else 0.5
      
      @displayPoints.push
        x: THREE.MathUtils.lerp startPoint.x, endPoint.x, segmentParameter
        y: THREE.MathUtils.lerp startPoint.y, endPoint.y, segmentParameter
        
    if @isClosed and (@displayPoints[0].x isnt @displayPoints[@displayPoints.length - 1].x or @displayPoints[0].y isnt @displayPoints[@displayPoints.length - 1].y)
      @displayPoints.push @displayPoints[0]
      
    if @displayPoints.length is 2
      startPoint = @line.getPoint @line.getEdgeSegment(@startSegmentIndex).endPointIndex
      endPoint = @line.getPoint @line.getEdgeSegment(@endSegmentIndex).startPointIndex
      
      @displayPoints.splice 1, 0,
        x: THREE.MathUtils.lerp startPoint.x, endPoint.x, 0.5
        y: THREE.MathUtils.lerp startPoint.y, endPoint.y, 0.5

  calculatePointConfidence: ->
    @pointConfidences = []
    
    previousConfidence = 0
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      continue unless segment.pointSegmentsCount
      
      nextSegment = null
      nextSegment = @line.getEdgeSegment segmentIndex + 1 if segmentIndex + 1 <= @endSegmentIndex
      nextSegment = @line.getEdgeSegment segmentIndex + 2 unless nextSegment?.pointSegmentsCount or segmentIndex + 2 > @endSegmentIndex
      
      if nextSegment
        nextConfidence = @_getConfidenceBetweenSegments segment, nextSegment
      
      else
        nextConfidence = 0
      
      pointsCount = segment.endPointIndex - segment.startPointIndex + 1
      
      for pointIndex in [segment.startPointIndex..segment.endPointIndex]
        pointParameter = (pointIndex - segment.startPointIndex + 1) / (pointsCount + 1)
        @pointConfidences[pointIndex] = THREE.MathUtils.lerp previousConfidence, nextConfidence, pointParameter
      
      previousConfidence = nextConfidence
      
  _getConfidenceBetweenSegments: (segmentA, segmentB) ->
    totalLength = segmentA.pointSegmentLength + segmentB.pointSegmentLength
    lengthDifference = Math.abs segmentA.pointSegmentLength - segmentB.pointSegmentLength
    maxLengthDifference = totalLength - 2

    maxConfidence = 3 / totalLength
    
    maxConfidence * lengthDifference / maxLengthDifference
