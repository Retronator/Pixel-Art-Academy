AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line::evaluate = ->
  return @_evaluation if @_evaluation
  
  widthType = @_analyzeWidthType()
  
  @_evaluation = {widthType}
  
  @_evaluation

PAE.Line::_analyzeWidthType = ->
  # Analyze single and double points.
  radiusCounts = _.countBy @points, 'radius'
  singleCount = radiusCounts[0.5]
  doubleCount = radiusCounts[1]
  
  return @constructor.WidthType.Variable if singleCount and doubleCount
  return @constructor.WidthType.Wide if doubleCount
  
  # We only have single points so we need to determine if the line is thin or thick.
  sideStepEdgeSegments = _.filter  @edgeSegments, (edgeSegment) => edgeSegment.isSideStep
  
  axisAlignedCount = _.countBy sideStepEdgeSegments, (edgeSegment) => edgeSegment.edge.isAxisAligned
  thinCount = axisAlignedCount[false]
  thickCount = axisAlignedCount[true]
  
  return @constructor.WidthType.Variable if thinCount and thickCount
  return @constructor.WidthType.Thick if thickCount
  @constructor.WidthType.Thin
