AE = Artificial.Everywhere
AP = Artificial.Pyramid
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Line.Part.StraightLine extends PAG.Line.Part
  @Type:
    AxisAligned: 'AxisAligned'
    EvenDiagonal: 'EvenDiagonal'
    IntermediaryDiagonal: 'IntermediaryDiagonal'
    
  @PointSegmentLengths:
    Even: 'Even'
    Alternating: 'Alternating'
    Broken: 'Broken'
    
  @EndPointSegmentLengths:
    Matching: 'Matching'
    Shorter: 'Shorter'
  
  constructor: ->
    super arguments...
    
    @line2 = new THREE.Line2
    PAG.Point.setStraightLine _.first(@points), _.last(@points), @line2
    
    @displayLine2 = @line2.clone()
    
  setNeighbors: ->
    super arguments...
    
    if @previousPart
      if @previousPart instanceof @constructor
        @line2.intersect @previousPart.line2, @displayLine2.start
        
      else
        @previousPart.projectToLine @previousPart.endPointIndex, @, @displayLine2.start
    
    if @nextPart
      if @nextPart instanceof @constructor
        @line2.intersect @nextPart.line2, @displayLine2.end
      
      else
        @nextPart.projectToLine @nextPart.startPointIndex, @, @displayLine2.end
        
  grade: ->
    return @_grading if @_grading
    
    @_analyzeSegments()
    
    diagonalRatio = @_analyzeDiagonalRatio()
    type = @_analyzeType diagonalRatio
    segmentLengths = @_analyzePointSegmentLengths()
    endSegments = @_analyzeEndPointSegmentLengths()
    
    @_grading = {type, diagonalRatio, segmentLengths, endSegments}
    
    @_grading
    
  _analyzeSegments: ->
    return if @pointSegmentLengths
    
    @pointSegmentLengths = []
    @pointSegmentLengthFrequency = []
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      if segment.pointSegmentsCount and segment.pointSegmentLength
        @pointSegmentLengths.push segment.pointSegmentLength for i in [1..segment.pointSegmentsCount]
      
      @pointSegmentLengthFrequency[segment.pointSegmentLength] ?= 0
      @pointSegmentLengthFrequency[segment.pointSegmentLength] += segment.pointSegmentsCount
      
    @uniquePointSegmentLengths = _.sortBy _.uniq @pointSegmentLengths
    @largestPointSegmentLengths = @uniquePointSegmentLengths[@uniquePointSegmentLengths.length - 2..]
  
  _analyzeDiagonalRatio: ->
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
    
    mostFrequentPointSegmentLengths = @pointSegmentLengthFrequency[@pointSegmentLengthFrequency.length - 2..]
    smallerPointSegmentLength = @pointSegmentLengthFrequency.length - 2
    largerPointSegmentLength = @pointSegmentLengthFrequency.length - 1
    
    if mostFrequentPointSegmentLengths[0] and mostFrequentPointSegmentLengths[1] and Math.abs(mostFrequentPointSegmentLengths[0] - mostFrequentPointSegmentLengths[1]) <= 1
      ratio = new AP.Fraction 2, smallerPointSegmentLength + largerPointSegmentLength
      
    else
      largerPointSegmentFrequency = @pointSegmentLengthFrequency[largerPointSegmentLength]
      smallerPointSegmentFrequency = @pointSegmentLengthFrequency[smallerPointSegmentLength]
      
      unless smallerPointSegmentFrequency and smallerPointSegmentFrequency > largerPointSegmentFrequency
        ratio = new AP.Fraction 1, largerPointSegmentLength
        
      else
        frequenciesCount = largerPointSegmentFrequency + smallerPointSegmentFrequency
        totalLength = largerPointSegmentFrequency * largerPointSegmentLength + smallerPointSegmentFrequency * smallerPointSegmentLength
        ratio = new AP.Fraction frequenciesCount, totalLength
        ratio.simplify()
    
    ratio.invert() if height > width
    ratio
    
  _analyzeType: (diagonalRatio) ->
    lowestNumber = Math.min diagonalRatio.numerator, diagonalRatio.denominator
    
    switch lowestNumber
      when 0 then @constructor.Type.AxisAligned
      when 1 then @constructor.Type.EvenDiagonal
      else @constructor.Type.IntermediaryDiagonal
    
  _analyzePointSegmentLengths: ->
    # If we have only one segment length, it's a perfect even diagonal.
    if @uniquePointSegmentLengths.length is 1
      return type: @constructor.PointSegmentLengths.Even, score: 1
    
    # The line is not perfect so we can calculate a ratio between its largest segments for scoring purposes.
    largestPointSegmentsLengthRatio = @largestPointSegmentLengths[0] / @largestPointSegmentLengths[1]

    # Alternating score can go from C (75%) at worst (1:2) to A at best (∞:∞).
    alternatingScore = THREE.MathUtils.mapLinear largestPointSegmentsLengthRatio, 0.5, 1, 0.75, 1
    
    # If we don't have enough segments to determine repetition, we classify as alternating as the next best thing.
    if @pointSegmentLengths.length <= 3
      return type: @constructor.PointSegmentLengths.Alternating, score: alternatingScore

    # We have at least 2 middle segments (besides 2 end ones) so we can check if they are alternating.
    oddPointSegmentLength = @pointSegmentLengths[1]
    evenPointSegmentLength = @pointSegmentLengths[2]
    
    for pointSegmentIndex in [1...@pointSegmentLengths.length - 1] by 2
      unless @pointSegmentLengths[pointSegmentIndex] is oddPointSegmentLength and @pointSegmentLengths[pointSegmentIndex + 1] is evenPointSegmentLength
        # We found a break in the repetition. We want to see what's the ratio between the frequency of each possible segment.
        largestPointSegmentsFrequency = _.sortBy(@pointSegmentLengthFrequency[pointSegmentLength] for pointSegmentLength in @largestPointSegmentLengths)
        largestPointSegmentsFrequencyRatio = largestPointSegmentsFrequency[0] / largestPointSegmentsFrequency[1]
        
        # Broken scores can go from F (50%) at worst (1:∞) to C (75%) at best (1:1).
        brokenScore = THREE.MathUtils.mapLinear largestPointSegmentsFrequencyRatio, 0, 1, 0.5, 0.75
        
        return type: @constructor.PointSegmentLengths.Broken, score: brokenScore
    
    # There was no break in repetition so this is a nicely alternating diagonal.
    type: @constructor.PointSegmentLengths.Alternating
    score: alternatingScore

  _analyzeEndPointSegmentLengths: ->
    result =
      type: @constructor.EndPointSegmentLengths.Matching,
      startScore: 1
      endScore: 1
      score: 1
      
    return result if @pointSegmentLengthFrequency[@pointSegmentLengths[0]] is @pointSegmentLengths.length

    firstPointSegmentLength = _.first @pointSegmentLengths
    endPointSegmentLength = _.last @pointSegmentLengths
    comparisonLength = _.min @largestPointSegmentLengths
  
    result.startScore = firstPointSegmentLength / comparisonLength unless firstPointSegmentLength in @largestPointSegmentLengths
    result.endScore = endPointSegmentLength / comparisonLength unless endPointSegmentLength in @largestPointSegmentLengths
    result.score = (result.startScore + result.endScore) / 2
    
    result.type = @constructor.EndPointSegmentLengths.Shorter unless result.score is 1
    
    result
