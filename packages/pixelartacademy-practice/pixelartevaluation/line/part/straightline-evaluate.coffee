AE = Artificial.Everywhere
AP = Artificial.Pyramid
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line.Part.StraightLine::evaluate = ->
  return @_evaluation if @_evaluation
  
  @_analyzeSegments()
  
  diagonalRatio = @_analyzeDiagonalRatio()
  type = @_analyzeType diagonalRatio
  segmentLengths = @_analyzePointSegmentLengths()
  endSegments = @_analyzeEndPointSegmentLengths()
  
  @_evaluation = {type, diagonalRatio, segmentLengths, endSegments}
  
  @_evaluation

PAE.Line.Part.StraightLine::_analyzeSegments = ->
  return if @pointSegmentLengths
  
  @pointSegmentLengths = []
  @pointSegmentLengthFrequency = []
  
  for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
    segment = @line.getEdgeSegment segmentIndex
    
    if segment.pointSegmentsCount and segment.pointSegmentLength
      pointSegmentLength = if segmentIndex in [@startSegmentIndex, @endSegmentIndex] then segment.externalPointSegmentLength else segment.pointSegmentLength
      @pointSegmentLengths.push pointSegmentLength for i in [1..segment.pointSegmentsCount]
    
    @pointSegmentLengthFrequency[pointSegmentLength] ?= 0
    @pointSegmentLengthFrequency[pointSegmentLength] += segment.pointSegmentsCount
    
  @startPointSegmentLength = null
  @endPointSegmentLength = null
  
  if @pointSegmentLengths.length < 3
    @centralPointSegmentLengths = @pointSegmentLengths
    
  else
    @centralPointSegmentLengths = @pointSegmentLengths[1...@pointSegmentLengths.length - 1]
    uniqueCentralPointSegmentLengths = _.sortBy _.uniq @centralPointSegmentLengths
    
    startPointSegmentLength = _.first @pointSegmentLengths
    endPointSegmentLength = _.last @pointSegmentLengths
    largestCentralPointSegmentLength = _.last uniqueCentralPointSegmentLengths

    if startPointSegmentLength in uniqueCentralPointSegmentLengths or startPointSegmentLength > largestCentralPointSegmentLength
      @centralPointSegmentLengths.unshift startPointSegmentLength
      
    else
      @startPointSegmentLength = startPointSegmentLength
    
    if endPointSegmentLength in uniqueCentralPointSegmentLengths or endPointSegmentLength > largestCentralPointSegmentLength
      @centralPointSegmentLengths.push endPointSegmentLength
    
    else
      @endPointSegmentLength = endPointSegmentLength
      
  @uniqueCentralPointSegmentLengths = _.sortBy _.uniq @centralPointSegmentLengths
  @largestCentralPointSegmentLengths = @uniqueCentralPointSegmentLengths[@uniqueCentralPointSegmentLengths.length - 2..]

PAE.Line.Part.StraightLine::_analyzeDiagonalRatio = ->
  @_analyzeSegments()
  
  start = _.first @points
  end = _.last @points
  width = Math.max(start.x, end.x) - Math.min(start.x, end.x) + 1
  height = Math.max(start.y, end.y) - Math.min(start.y, end.y) + 1
  
  unless width > 1 and height > 1
    if height is 1
      return new AP.Fraction 0, width
      
    else
      return new AP.Fraction height, 0
      
  if @largestCentralPointSegmentLengths.length is 1
    ratio = new AP.Fraction 1, @largestCentralPointSegmentLengths[0]
    
  else
    smallerPointSegmentLength = @largestCentralPointSegmentLengths[0]
    largerPointSegmentLength = @largestCentralPointSegmentLengths[1]
    
    smallerPointSegmentFrequency = @pointSegmentLengthFrequency[smallerPointSegmentLength]
    largerPointSegmentFrequency = @pointSegmentLengthFrequency[largerPointSegmentLength]
    
    if Math.abs(smallerPointSegmentFrequency - largerPointSegmentFrequency) <= 1
      ratio = new AP.Fraction 2, smallerPointSegmentLength + largerPointSegmentLength
      
    else
      frequenciesCount = largerPointSegmentFrequency + smallerPointSegmentFrequency
      totalLength = largerPointSegmentFrequency * largerPointSegmentLength + smallerPointSegmentFrequency * smallerPointSegmentLength
      ratio = new AP.Fraction frequenciesCount, totalLength
      ratio.simplify()
  
  ratio.invert() if height > width
  ratio

PAE.Line.Part.StraightLine::_analyzeType = (diagonalRatio) ->
  lowestNumber = Math.min diagonalRatio.numerator, diagonalRatio.denominator
  
  switch lowestNumber
    when 0 then @constructor.Type.AxisAligned
    when 1 then @constructor.Type.EvenDiagonal
    else @constructor.Type.IntermediaryDiagonal

PAE.Line.Part.StraightLine::_analyzePointSegmentLengths = ->
  # If we have only one segment length, it's a perfect even diagonal.
  if @uniqueCentralPointSegmentLengths.length is 1
    return type: @constructor.SegmentLengths.Even, score: 1
  
  # The line is not perfect so we can calculate a ratio between its largest segments for scoring purposes.
  largestPointSegmentsLengthRatio = @largestCentralPointSegmentLengths[0] / @largestCentralPointSegmentLengths[1]

  # Alternating score can go from C (75%) at worst (1:2) to A at best (∞:∞).
  alternatingScore = THREE.MathUtils.mapLinear largestPointSegmentsLengthRatio, 0.5, 1, 0.75, 1
  
  oddPointSegmentLength = @centralPointSegmentLengths[0]
  evenPointSegmentLength = @centralPointSegmentLengths[1]
  
  for pointSegmentIndex in [0...@centralPointSegmentLengths.length] by 2
    unless @centralPointSegmentLengths[pointSegmentIndex] is oddPointSegmentLength and (@centralPointSegmentLengths[pointSegmentIndex + 1] is evenPointSegmentLength or pointSegmentIndex > @centralPointSegmentLengths.length - 2)
      # We found a break in the repetition. We want to see what's the ratio between the frequency of each possible segment.
      largestPointSegmentsFrequency = _.sortBy(@pointSegmentLengthFrequency[pointSegmentLength] for pointSegmentLength in @largestCentralPointSegmentLengths)
      largestPointSegmentsFrequencyRatio = largestPointSegmentsFrequency[0] / largestPointSegmentsFrequency[1]
      
      # Broken scores can go from F (50%) at worst (1:∞) to C (75%) at best (1:1).
      brokenScore = THREE.MathUtils.mapLinear largestPointSegmentsFrequencyRatio, 0, 1, 0.5, 0.75
      
      return type: @constructor.SegmentLengths.Broken, score: brokenScore
  
  # There was no break in repetition so this is a nicely alternating diagonal.
  type: @constructor.SegmentLengths.Alternating
  score: alternatingScore

PAE.Line.Part.StraightLine::_analyzeEndPointSegmentLengths = ->
  result =
    type: @constructor.EndSegments.Matching,
    startScore: null
    endScore: null
    score: 1
    
  return result unless @startPointSegmentLength or @endPointSegmentLength
  
  comparisonLength = _.min @largestCentralPointSegmentLengths

  result.startScore = @startPointSegmentLength / comparisonLength if @startPointSegmentLength
  result.endScore = @endPointSegmentLength / comparisonLength if @endPointSegmentLength
  result.score = ((result.startScore ? 1) + (result.endScore ? 1)) / 2
  result.type = @constructor.EndSegments.Shorter
  
  result
