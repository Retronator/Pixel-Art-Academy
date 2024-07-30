AE = Artificial.Everywhere
AP = Artificial.Pyramid
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line.Part.Curve::evaluate = ->
  return @_evaluation if @_evaluation
  
  @_analyzeSegments()
  
  pointSegmentLengthChanges = @_analyzePointSegmentLengthChanges()
  
  @_evaluation = {pointSegmentLengthChanges}
  
  @_evaluation

PAE.Line.Part.Curve::_analyzeSegments = ->
  return if @pointSegmentLengths
  
  @pointSegmentLengths = []
  
  for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
    segment = @line.getEdgeSegment segmentIndex
    
    if segment.pointSegmentsCount and segment.pointSegmentLength
      pointSegmentLength = if segmentIndex in [@startSegmentIndex, @endSegmentIndex] then segment.externalPointSegmentLength else segment.pointSegmentLength
      @pointSegmentLengths.push pointSegmentLength for i in [1..segment.pointSegmentsCount]
      
  @pointSegmentLengthChanges = []
  
  for pointSegmentLengthIndex in [0...@pointSegmentLengths.length - 1]
    @pointSegmentLengthChanges.push Math.abs @pointSegmentLengths[pointSegmentLengthIndex + 1] - @pointSegmentLengths[pointSegmentLengthIndex]
  
PAE.Line.Part.Curve::_analyzePointSegmentLengthChanges = ->
  abruptPointSegmentLengthChanges = []
  
  # Changes are abrupt when going from 0 change to a big change.
  for pointSegmentLengthChange, changeIndex in @pointSegmentLengthChanges when pointSegmentLengthChange is 0
    # Allow the neighboring segment length change to be as long as the segment itself.
    pointSegmentLength = @pointSegmentLengths[changeIndex]
    
    for neighborIndex in [changeIndex - 1, changeIndex + 1]
      continue unless neighborPointSegmentLengthChange = @pointSegmentLengthChanges[neighborIndex]
      continue unless abruptIncrease = Math.max 0, neighborPointSegmentLengthChange - pointSegmentLength
      
      abruptPointSegmentLengthChanges.push
        index: neighborIndex
        abruptIncrease: abruptIncrease
    
  # There was no break in repetition so this is a nicely alternating diagonal.
  {abruptPointSegmentLengthChanges, count: @pointSegmentLengthChanges.length}
