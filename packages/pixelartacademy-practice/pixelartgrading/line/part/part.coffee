AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Line.Part
  constructor: (@line, @startSegmentIndex, @endSegmentIndex, @startPointIndex, @endPointIndex) ->
    @id = Random.id()
    
    displayStartPointIndex = @startPointIndex
    displayEndPointIndex = @endPointIndex
    
    @startPointIndex ?= @line.getEdgeSegment(@startSegmentIndex).startPointIndex
    @endPointIndex ?= @line.getEdgeSegment(@endSegmentIndex).endPointIndex
    
    displayStartPointIndex ?= @line.getEdgeSegment(@startSegmentIndex).displayStartPointIndex
    displayEndPointIndex ?= @line.getEdgeSegment(@endSegmentIndex).displayEndPointIndex
    
    # Collect points.
    @points = []
    @displayPoints = []
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      if segment.startPointIndex?
        startPointIndex = segment.startPointIndex
        endPointIndex = segment.endPointIndex
        
        startPointIndex = Math.max startPointIndex, @startPointIndex if segmentIndex is @startSegmentIndex
        endPointIndex = Math.min endPointIndex, @endPointIndex if segmentIndex is @endSegmentIndex
        
        for pointIndex in [startPointIndex..endPointIndex]
          point = @line.getPoint pointIndex
          @points.push point
      
      startPointIndex = segment.displayStartPointIndex
      endPointIndex = segment.displayEndPointIndex
      
      startPointIndex = Math.max startPointIndex, displayStartPointIndex if segmentIndex is @startSegmentIndex
      endPointIndex = Math.min endPointIndex, displayEndPointIndex if segmentIndex is @endSegmentIndex
      
      for pointIndex in [startPointIndex..endPointIndex]
        point = @line.getPoint pointIndex
        @displayPoints.push point unless point is @displayPoints[@displayPoints.length - 1]
        
  calculatePointConfidence: -> throw new AE.NotImplementedException "Line part must provide confidence calculation."
