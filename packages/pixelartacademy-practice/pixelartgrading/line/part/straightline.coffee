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
    @_analyzeSegments()
    
    diagonalRatio = @_analyzeDiagonalRatio()
    type = @_analyzeType diagonalRatio
    pointSegmentLengths = @_analyzePointSegmentLengths()
    endPointSegmentLengths = @_analyzeEndPointSegmentLengths()
    
    {type, diagonalRatio, pointSegmentLengths, endPointSegmentLengths}
    
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
    uniquePointSegmentLengths = _.sortBy _.uniq @pointSegmentLengths

    return @constructor.PointSegmentLengths.Even if uniquePointSegmentLengths.length is 1
    
    return @constructor.PointSegmentLengths.Alternating if @pointSegmentLengths.length is 2
    
    if @pointSegmentLengths.length is 3
      return if @pointSegmentLengths[0] is @pointSegmentLengths[2] then @constructor.PointSegmentLengths.Alternating else @constructor.PointSegmentLengths.Broken
    
    oddPointSegmentLength = @pointSegmentLengths[1]
    evenPointSegmentLength = @pointSegmentLengths[2]
    
    for pointSegmentIndex in [1...@pointSegmentLengths.length - 1] by 2
      return @constructor.PointSegmentLengths.Broken unless @pointSegmentLengths[pointSegmentIndex] is oddPointSegmentLength and @pointSegmentLengths[pointSegmentIndex + 1] is evenPointSegmentLength
      
    @constructor.PointSegmentLengths.Alternating

  _analyzeEndPointSegmentLengths: ->
    return @constructor.EndPointSegmentLengths.Matching if @pointSegmentLengths.length is 1
    return @constructor.EndPointSegmentLengths.Matching if @pointSegmentLengths.length is 2 and @pointSegmentLengths[0] is @pointSegmentLengths[1]
    return @constructor.EndPointSegmentLengths.Matching if @pointSegmentLengths.length is 3 and @pointSegmentLengths[0] is @pointSegmentLengths[2] and Math.abs(@pointSegmentLengths[1] - @pointSegmentLengths[0]) <= 1
    return @constructor.EndPointSegmentLengths.Matching if @pointSegmentLengths[0] is @pointSegmentLengths[2] and @pointSegmentLengths[1] is @pointSegmentLengths[3]
    @constructor.EndPointSegmentLengths.Shorter
