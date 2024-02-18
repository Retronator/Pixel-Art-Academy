AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PAE.Line::_analyzeCurvature = ->
  # Detect inflection points.
  currentCurveClockwise = null
  inflectionAreaStartEdgeSegmentIndex = null
  inflectionAreaEndEdgeSegmentIndex = null
  
  for edgeSegmentIndex in [0...@edgeSegments.length]
    edgeSegment = @getEdgeSegment edgeSegmentIndex
    
    # Set initial curvature.
    currentCurveClockwise ?= edgeSegment.curveClockwise.after
    continue unless currentCurveClockwise?
    
    # Continue until curvature is defined.
    continue unless edgeSegment.curveClockwise.after?
    
    # Keep searching for the start of the inflection area if we're in the area of same curvature.
    if edgeSegment.curveClockwise.after is currentCurveClockwise
      # The direction after is the same, push the start of the inflection area forward.
      inflectionAreaStartEdgeSegmentIndex = edgeSegmentIndex + 1
      continue
    
    # We've reached a different curvature, this is the end of the inflection area.
    inflectionAreaEndEdgeSegmentIndex = edgeSegmentIndex

    @inflectionPoints.push
      # Find the point in the center of the inflection area.
      position: @getCentralSegmentPosition inflectionAreaStartEdgeSegmentIndex, inflectionAreaEndEdgeSegmentIndex
      averagePointIndex: @getCentralSegmentAveragePointIndex inflectionAreaStartEdgeSegmentIndex, inflectionAreaEndEdgeSegmentIndex
      inflectionArea:
        startEdgeSegmentIndex: inflectionAreaStartEdgeSegmentIndex
        endEdgeSegmentIndex: inflectionAreaEndEdgeSegmentIndex
        averageEdgeSegmentIndex: (inflectionAreaStartEdgeSegmentIndex + inflectionAreaEndEdgeSegmentIndex) / 2

    # Continue searching for the inflection area after the current curvature starts changing.
    currentCurveClockwise = edgeSegment.curveClockwise.after
    inflectionAreaStartEdgeSegmentIndex = edgeSegmentIndex + 1
  
  # Detect curves for displaying curvature changes. First, find the initial curve direction.
  for segmentIndex in [0...@edgeSegments.length]
    edgeSegment = @edgeSegments[segmentIndex]
    
    # Curvature curves start at changes of curvature.
    clockwise = edgeSegment.curveClockwise.after
    break if clockwise?
    
  return unless clockwise?
  
  # Create curve parts between inflection points.
  addCurvatureCurvePart = (startSegmentIndex, endSegmentIndex, startPointIndex, endPointIndex, clockwise) =>
    # Fully closed curves don't have a curvature.
    return if endSegmentIndex >= startSegmentIndex + @edgeSegments.length
    
    @curvatureCurveParts.push new PAE.Line.Part.Curve @, startSegmentIndex, endSegmentIndex, startPointIndex, endPointIndex, false, clockwise
    
  startSegmentIndex = 0
  startPointIndex = 0
  
  for inflectionPoint in @inflectionPoints
    endSegmentIndex = Math.ceil inflectionPoint.inflectionArea.averageEdgeSegmentIndex
    endPointIndex = Math.ceil inflectionPoint.averagePointIndex
    addCurvatureCurvePart startSegmentIndex, endSegmentIndex, startPointIndex, endPointIndex, clockwise
    
    startSegmentIndex = Math.floor inflectionPoint.inflectionArea.averageEdgeSegmentIndex
    startPointIndex = Math.floor inflectionPoint.averagePointIndex
    clockwise = not clockwise

  endSegmentIndex = @edgeSegments.length - 1
  endPointIndex = @points.length - 1
  addCurvatureCurvePart startSegmentIndex, endSegmentIndex, startPointIndex, endPointIndex, clockwise
  
  # Remove inflection points that are in or bordering straight areas.
  _.remove @inflectionPoints, (inflectionPoint) => not (@pointPartIsCurve[Math.floor inflectionPoint.averagePointIndex] and @pointPartIsCurve[Math.ceil inflectionPoint.averagePointIndex])
