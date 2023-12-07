AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Line.Part
  constructor: (@line, @startSegmentIndex, @endSegmentIndex, @startPointIndex, @endPointIndex) ->
    @id = Random.id()
    
    @startPointIndex ?= @line.getEdgeSegment(@startSegmentIndex).startPointIndex
    @endPointIndex ?= @line.getEdgeSegment(@endSegmentIndex).endPointIndex
    
    # Collect points.
    @points = []
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      if segment.startPointIndex?
        startPointIndex = segment.startPointIndex
        endPointIndex = segment.endPointIndex
        
        startPointIndex = Math.max startPointIndex, @startPointIndex if segmentIndex is @startSegmentIndex
        endPointIndex = Math.min endPointIndex, @endPointIndex if segmentIndex is @endSegmentIndex
        
        for pointIndex in [startPointIndex..endPointIndex]
          point = @line.getPoint pointIndex
          @points.push point unless point in @points
  
  overlaysPointRange: (startPointIndex, endPointIndex) ->
    pointCount = @line.points.length
    startPointIndex = startPointIndex % pointCount
    endPointIndex = endPointIndex % pointCount

    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      if endPointIndex >= startPointIndex
        return true if startPointIndex <= segment.endPointIndex and endPointIndex >= segment.startPointIndex
        
      else
        return true if startPointIndex <= segment.endPointIndex or endPointIndex >= segment.startPointIndex

    false
  
  setNeighbors: (@previousPart, @nextPart) ->
    # Extend to adjust display points.
