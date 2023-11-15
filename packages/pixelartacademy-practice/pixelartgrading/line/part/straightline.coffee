AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Line.Part.StraightLine extends PAG.Line.Part
  constructor: (..., @averageSegmentCount) ->
    super arguments...
    
    # Only keep the starting and ending display point.
    @displayPoints = [_.first(@displayPoints), _.last(@displayPoints)]

  calculatePointConfidence: ->
    @pointConfidences = []
    
    previousConfidence = 0
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      continue unless segment.pointSegmentsCount
      
      nextSegment = null
      nextSegment = @line.getEdgeSegment segmentIndex + 1 if segmentIndex + 1 <= @endSegmentIndex
      nextSegment = @line.getEdgeSegment segmentIndex + 2 unless nextSegment?.pointSegmentsCount or segmentIndex + 2 > @endSegmentIndex
      
      if segment.pointSegmentLength is 1
        for pointIndex in [segment.startPointIndex..segment.endPointIndex]
          nextCalculatingSegment = if pointIndex is segment.endPointIndex then nextSegment else segment
          
          if nextCalculatingSegment
            nextConfidence = @_getConfidenceBetweenSegments segment, nextCalculatingSegment
            
          else
            nextConfidence = 0
            
          @pointConfidences[pointIndex] = THREE.MathUtils.lerp previousConfidence, nextConfidence, 0.5
          
          previousConfidence = nextConfidence
        
      else
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
    difference = Math.abs segmentA.pointSegmentLength - segmentB.pointSegmentLength
    
    switch difference
      when 0 then 1
      when 1 then 0.75
      else 0.5
