AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Line.Part.StraightLine extends PAG.Line.Part
  constructor: (..., @averageSegmentCount) ->
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
