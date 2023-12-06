AE = Artificial.Everywhere
AP = Artificial.Pyramid
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Line.Part.StraightLine extends PAG.Line.Part
  constructor: ->
    super arguments...
    
    @line2 = new THREE.Line2
    PAG.Point.setStraightLine _.first(@points), _.last(@points), @line2
    
    @displayLine2 = @line2.clone()
    
    @segmentLengthFrequency = []
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      @segmentLengthFrequency[segment.pointSegmentLength] ?= 0
      @segmentLengthFrequency[segment.pointSegmentLength] += segment.pointSegmentsCount
    
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

  diagonalRatio: ->
    start = _.first @points
    end = _.last @points
    width = Math.max(start.x, end.x) - Math.min(start.x, end.x) + 1
    height = Math.max(start.y, end.y) - Math.min(start.y, end.y) + 1
    
    return unless width > 1 and height > 1
    
    mostFrequentSegmentLengths = @segmentLengthFrequency[@segmentLengthFrequency.length - 2..]
    smallerSegmentLength = @segmentLengthFrequency.length - 2
    largerSegmentLength = @segmentLengthFrequency.length - 1
    
    if mostFrequentSegmentLengths[0] and mostFrequentSegmentLengths[1] and Math.abs(mostFrequentSegmentLengths[0] - mostFrequentSegmentLengths[1]) <= 1
      ratio = new AP.Fraction 2, smallerSegmentLength + largerSegmentLength
      
    else
      largerSegmentFrequency = @segmentLengthFrequency[largerSegmentLength]
      smallerSegmentFrequency = @segmentLengthFrequency[smallerSegmentLength]
      
      unless smallerSegmentFrequency and smallerSegmentFrequency > largerSegmentFrequency
        ratio = new AP.Fraction 1, largerSegmentLength
        
      else
        frequenciesCount = largerSegmentFrequency + smallerSegmentFrequency
        totalLength = largerSegmentFrequency * largerSegmentLength + smallerSegmentFrequency * smallerSegmentLength
        ratio = new AP.Fraction frequenciesCount, totalLength
        ratio.simplify()
    
    ratio.invert() if height > width
    ratio
