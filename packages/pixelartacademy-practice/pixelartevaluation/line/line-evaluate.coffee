AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line::evaluate = ->
  return @_evaluation if @_evaluation
  
  doubles = @_analyzeDoubles()
  corners = @_analyzeCorners()
  width = @_analyzeWidth()
  curveSmoothness = @_analyzeCurveSmoothness()
  
  @_evaluation = {width, doubles, corners, curveSmoothness}
  
  @_evaluation
  
PAE.Line::_analyzeDoubles = ->
  doubles = @getDoubles()
  
  # Side-steps need to be diagonals instead of axis-aligned.
  sideStepsCount = 0
  diagonalSideStepsCount = 0
  
  for edgeSegment in @edgeSegments when edgeSegment.isSideStep
    sideStepsCount++
    diagonalSideStepsCount++ unless edgeSegment.edge.isAxisAligned
    
  sideStepScore = if sideStepsCount then diagonalSideStepsCount / sideStepsCount else 1
  
  score: sideStepScore
  count: doubles.length
  pixels: doubles

PAE.Line::_analyzeCorners = ->
  corners = @getCorners()

  # Count how many total transitions there were on this line so we can compare how many of these are corners.
  transitionsCount = 0

  for edgeSegment, edgeSegmentIndex in @edgeSegments when not edgeSegment.isSideStep
    break unless nextEdgeSegment = @getEdgeSegment edgeSegmentIndex + 1
    continue if nextEdgeSegment.isSideStep
    transitionsCount++
    
  score: if transitionsCount then 1 - corners.length / transitionsCount else 1
  count: corners.length
  pixels: corners

PAE.Line::_analyzeWidth = ->
  # Analyze single and double points.
  radiusCounts = _.countBy @points, 'radius'
  singleCount = radiusCounts[0.5] or 0
  doubleCount = radiusCounts[1] or 0
  
  if doubleCount and not singleCount
    return type: @constructor.WidthType.Wide, score: 1
  
  score = Math.abs 2 * singleCount / (singleCount + doubleCount) - 1
  
  # We have some single points so we need to determine if those are thin or thick.
  sideStepEdgeSegments = _.filter  @edgeSegments, (edgeSegment) => edgeSegment.isSideStep
  
  if sideStepEdgeSegments.length
    axisAlignedCount = _.countBy sideStepEdgeSegments, (edgeSegment) => edgeSegment.edge.isAxisAligned
    thinCount = axisAlignedCount[false] or 0
    thickCount = axisAlignedCount[true] or 0
    
    score *= Math.abs 2 * thinCount / (thinCount + thickCount) - 1
  
  if thinCount and thickCount or singleCount and doubleCount
    # Varying width type should have the score of 0.9 (B) or less.
    return type: @constructor.WidthType.Varying, score: score * 0.9
    
  type: if thinCount then @constructor.WidthType.Thin else @constructor.WidthType.Thick
  score: 1

PAE.Line::_analyzeCurveSmoothness = ->
  # Nothing to do if we don't have curved parts.
  curveParts = _.filter @parts, (part) => part instanceof @constructor.Part.Curve
  return unless curveParts.length
  
  # Calculate abrupt segment length changes score.
  pointSegmentLengthChangesCount = 0
  pointSegmentLengthChangesAbruptIncrease = 0
  
  abruptPointSegmentLengthChangesCounts =
    minor: 0
    major: 0
  
  for curvePart in curveParts
    {pointSegmentLengthChanges} = curvePart.evaluate()
    
    pointSegmentLengthChangesCount += pointSegmentLengthChanges.count
    
    for abruptPointSegmentLengthChange in pointSegmentLengthChanges.abruptPointSegmentLengthChanges
      # Apply a cap on how much the increase in abruptness affects the score.
      pointSegmentLengthChangesAbruptIncrease += Math.min 3, abruptPointSegmentLengthChange.abruptIncrease
  
      if abruptPointSegmentLengthChange.abruptIncrease >= PAE.Line.Part.Curve.majorAbruptIncreaseThreshold
        abruptPointSegmentLengthChangesCounts.major++

      else
        abruptPointSegmentLengthChangesCounts.minor++
        
  abruptPointSegmentLengthChangesScore = 1
  
  # We multiply the increase by 1.2 so that a single minor abrupt change (with 2 changes) gives a score of 0.6 (D grade).
  abruptPointSegmentLengthChangesScore -= pointSegmentLengthChangesAbruptIncrease * 1.2 / pointSegmentLengthChangesCount if pointSegmentLengthChangesCount

  # Calculate straight parts score.
  straightParts = _.filter @parts, (part) => part instanceof @constructor.Part.StraightLine
  endingParts = if @isClosed then [] else [_.first(@parts), _.last(@parts)]
  
  straightPartsCounts =
    middle: 0
    end: 0
  
  for straightPart in straightParts
    # End straight lines are less problematic.
    if straightPart in endingParts
      straightPartsCounts.end++
      
    else
      straightPartsCounts.middle++

  # Count how many straight points there are on the line. Note that we can't do this by finding how many
  # points the straight line parts have since those reach into the areas that are overlapped by curves.
  straightPointsCountMiddle = 0
  straightPointsCountEnd = 0
  middlePartStartPointIndex = 0
  middlePartEndPointIndex = @points.length - 1
  
  for pointIndex in [0..@points.length - 1]
    break if @pointPartIsCurve[pointIndex]
    straightPointsCountEnd++
    middlePartStartPointIndex = pointIndex + 1
  
  for pointIndex in [@points.length - 1..0] by -1
    break if @pointPartIsCurve[pointIndex]
    straightPointsCountEnd++
    middlePartEndPointIndex = pointIndex - 1
  
  if straightPointsCountEnd > @points.length
    # This is a fully straight line.
    straightPointsCountEnd = @points.length
    
  else
    straightPointsCountMiddle++ for pointIndex in [middlePartStartPointIndex..middlePartEndPointIndex] when not @pointPartIsCurve[pointIndex]

  if @isClosed
    straightPointsCountMiddle += straightPointsCountEnd
    straightPointsCountEnd = false
  
  # Straight parts are scored worse when they are at a 50:50 balance with curve parts.
  # As the straight parts start overtaking curved parts, they become less problematic again.
  straightPointsCount = straightPointsCountMiddle + straightPointsCountEnd
  
  if straightPointsCount
    straightPointsScore = 2 * Math.abs 0.5 - straightPointsCount / @points.length
    middlePointsScore = straightPointsScore
  
    # We limit ending parts to only go to a 0.7 score (D) at 50% coverage.
    endPointsScore = 0.7 + 0.3 * straightPointsScore
    straightPartsScore = THREE.MathUtils.lerp endPointsScore, middlePointsScore, straightPointsCountMiddle / straightPointsCount
    
  else
    straightPartsScore = 1
  
  # Calculate inflection points score.
  inflectionPoints = @_analyzeInflectionPoints()
  
  inflectionPointCounts =
    isolated: 0
    sparse: 0
    dense: 0
  
  if inflectionPoints.length
    inflectionPointsScore = 0
    
    for inflectionPoint in inflectionPoints
      inflectionPointsScore += inflectionPoint.spacingScore
      
      if inflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.dense
        inflectionPointCounts.dense++
        
      else if inflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.sparse
        inflectionPointCounts.sparse++
        
      else
        inflectionPointCounts.isolated++
    
    inflectionPointsScore /= inflectionPoints.length
    
  else
    inflectionPointsScore = 1
  
  abruptSegmentLengthChanges:
    score: abruptPointSegmentLengthChangesScore
    counts: abruptPointSegmentLengthChangesCounts
  straightParts:
    score: straightPartsScore
    counts: straightPartsCounts
  inflectionPoints:
    score: inflectionPointsScore
    counts: inflectionPointCounts
    points: inflectionPoints

PAE.Line::_analyzeInflectionPoints = ->
  inflectionPoints = []
  
  for inflectionPoint, inflectionPointIndex in @inflectionPoints
    previousInflectionPoint = @inflectionPoints[inflectionPointIndex - 1]
    nextInflectionPoint = @inflectionPoints[inflectionPointIndex + 1]
    
    # TODO: Add support for closed lines if points are not found.
    
    segmentDistanceFromPreviousInflectionPoint = Number.POSITIVE_INFINITY
    segmentDistanceFromNextInflectionPoint = Number.POSITIVE_INFINITY

    segmentDistanceFromPreviousInflectionPoint = inflectionPoint.inflectionArea.averageEdgeSegmentIndex - previousInflectionPoint.inflectionArea.averageEdgeSegmentIndex if previousInflectionPoint
    segmentDistanceFromNextInflectionPoint = nextInflectionPoint.inflectionArea.averageEdgeSegmentIndex - inflectionPoint.inflectionArea.averageEdgeSegmentIndex if nextInflectionPoint
    
    segmentDistanceFromClosestInflectionPoint = Math.min segmentDistanceFromPreviousInflectionPoint, segmentDistanceFromNextInflectionPoint
    
    inflectionPoints.push _.extend {}, inflectionPoint,
      # We add 0.5 to the distance so that a distance of 2 leads to a score of 0.6 (D).
      spacingScore: 1 - 1 / (0.5 + segmentDistanceFromClosestInflectionPoint)
  
  inflectionPoints
