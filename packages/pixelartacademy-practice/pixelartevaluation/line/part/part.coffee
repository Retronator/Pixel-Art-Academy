AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAE.Line.Part
  constructor: (@line, @startSegmentIndex, @endSegmentIndex, @startPointIndex, @endPointIndex) ->
    @id = Random.id()
    
    @startPointIndex ?= @line.getEdgeSegment(@startSegmentIndex).startPointIndex
    @endPointIndex ?= @line.getEdgeSegment(@endSegmentIndex).endPointIndex
    
    # Collect points.
    @points = []
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      startPointIndex = segment.startPointIndex
      endPointIndex = segment.endPointIndex
      
      startPointIndex = Math.max startPointIndex, @startPointIndex if segmentIndex is @startSegmentIndex
      endPointIndex = Math.min endPointIndex, @endPointIndex if segmentIndex is @endSegmentIndex
      
      for pointIndex in [startPointIndex..endPointIndex]
        point = @line.getPoint pointIndex
        @points.push point unless point in @points
        
  hasPixel: (pixel) ->
    for point in @points
      return true if pixel in point.pixels
      
    false
  
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
        
      # Special case for the segment that is closing an outline.
      if segment.endPointIndex is pointCount
        if endPointIndex >= startPointIndex
          return true if startPointIndex is 0
          
        else
          return true

    false
  
  setNeighbors: (@previousPart, @nextPart) ->
    # Extend to adjust display points.
    
  startsOnACorner: ->
    return true unless preStartSegment = @line.getEdgeSegment @startSegmentIndex - 1
    
    preStartSegment.corner.after
  
  endsOnACorner: ->
    endSegment = @line.getEdgeSegment @endSegmentIndex
    endSegment.corner.after
