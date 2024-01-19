AE = Artificial.Everywhere
AP = Artificial.Pyramid
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAE.Line.Part.StraightLine extends PAE.Line.Part
  @Type:
    AxisAligned: 'AxisAligned'
    EvenDiagonal: 'EvenDiagonal'
    IntermediaryDiagonal: 'IntermediaryDiagonal'
    
  @SegmentLengths:
    Even: 'Even'
    Alternating: 'Alternating'
    Broken: 'Broken'
    
  @EndSegments:
    Matching: 'Matching'
    Shorter: 'Shorter'
  
  constructor: ->
    super arguments...
    
    @line2 = new THREE.Line2
    PAE.Point.setStraightLine _.first(@points), _.last(@points), @line2
    
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
