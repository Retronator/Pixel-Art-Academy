AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtGrading

class PAG.Line.Part.StraightLine extends PAG.Line.Part
  constructor: (..., @averageSegmentCount) ->
    super arguments...
    
    # Only keep the starting and ending display point.
    @displayPoints = [_.first(@points), _.last(@points)]
