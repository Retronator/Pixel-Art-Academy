AE = Artificial.Everywhere
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

_point = new THREE.Vector2

class PAE.Line.Part.Curve extends PAE.Line.Part
  @AbruptSegmentLengthChanges:
    Minor: 'Minor'
    Major: 'Major'
  
  @StraightParts:
    End: 'End'
    Middle: 'Middle'
  
  @InflectionPoints:
    Isolated: 'Isolated'
    Sparse: 'Sparse'
    Dense: 'Dense'
  
  @majorAbruptIncreaseThreshold = 2
  
  @inflectionPointSpacingThresholds:
    dense: 0.6 # F
    sparse: 0.9 # E-B
  
  # Note: We must not use @ on the parameters that will be (re)assigned
  # in the parent since we'd otherwise overwrite their values.
  constructor: (line, startSegmentIndex, endSegmentIndex, startPointIndex, endPointIndex, @isClosed, @clockwise) ->
    super arguments...

    # Create display points.
    @displayPoints = []
    
    segmentParameter = 0.5
    
    for segmentIndex in [@startSegmentIndex..@endSegmentIndex]
      segment = @line.getEdgeSegment segmentIndex
      
      # Exclude side-step segments from generating curve points, except at end points.
      continue unless segment.pointSegmentsCount or segmentIndex in [@startSegmentIndex, @endSegmentIndex]
      
      startPointIndex = segment.startPointIndex
      endPointIndex = segment.endPointIndex
      
      startPointIndex = Math.max startPointIndex, @startPointIndex if segmentIndex is @startSegmentIndex
      endPointIndex = Math.min endPointIndex, @endPointIndex if segmentIndex is @endSegmentIndex
      
      startPoint = @line.getPoint startPointIndex
      endPoint = @line.getPoint endPointIndex
      
      unless @isClosed
        segmentParameter = switch segmentIndex
          when @startSegmentIndex then 0
          when @endSegmentIndex then 1
          else 0.5
        
      @displayPoints.push @_createDisplayPoint new THREE.Vector2().lerpVectors startPoint, endPoint, segmentParameter
      
    if @isClosed and (@displayPoints[0].x isnt @displayPoints[@displayPoints.length - 1].x or @displayPoints[0].y isnt @displayPoints[@displayPoints.length - 1].y)
      @displayPoints.push @displayPoints[0]
    
    if @displayPoints.length is 2
      @displayPoints.splice 1, 0, @_createDisplayPoint new THREE.Vector2().copy @line.getCentralSegmentPosition @startSegmentIndex, @endSegmentIndex
      
    if @displayPoints.length is 1
      @displayPoints.push @_createDisplayPoint @displayPoints[0].position.clone()
    
    @_calculateControlPoints 0, @displayPoints.length - 1
  
  _createDisplayPoint: (position) ->
    position: position
    tangent: new THREE.Vector2
    controlPoints:
      before: new THREE.Vector2
      after: new THREE.Vector2
  
  _calculateControlPoints: (displayPointStartIndex, displayPointEndIndex) ->
    for index in [displayPointStartIndex..displayPointEndIndex]
      point = @displayPoints[index]
      previousPoint = if @isClosed then @displayPoints[_.modulo index - 1, @displayPoints.length] else @displayPoints[index - 1]
      nextPoint = if @isClosed then @displayPoints[_.modulo index + 1, @displayPoints.length] else @displayPoints[index + 1]
      
      # Calculate the tangent.
      unless previousPoint
        if @previousPart and not @previousPart.endsOnACorner()
          @previousPart.line2.delta point.tangent
        
        else
          point.tangent.subVectors nextPoint.position, point.position
          
      else unless nextPoint
        if @nextPart and not @nextPart.startsOnACorner()
          @nextPart.line2.delta point.tangent
        
        else
          point.tangent.subVectors point.position, previousPoint.position
          
      else
        point.tangent.subVectors nextPoint.position, previousPoint.position
        
      point.tangent.normalize()
      
      # Calculate control points.
      if previousPoint
        distance = point.position.distanceTo previousPoint.position
        point.controlPoints.before.copy(point.tangent).multiplyScalar(-distance / 3).add point.position
        
      if nextPoint
        distance = point.position.distanceTo nextPoint.position
        point.controlPoints.after.copy(point.tangent).multiplyScalar(distance / 3).add point.position
        
    # Explicit return to prevent result collection.
    null
  
  setNeighbors: ->
    super arguments...
    
    # Remove the middle point in 3 point curves for a smoother transition.
    @displayPoints.splice 1, 1 if @displayPoints.length is 3
    
    if @previousPart
      @projectToLine @startPointIndex, @previousPart, @displayPoints[0].position
      @_calculateControlPoints 0, 1
    
    if @nextPart
      @projectToLine @endPointIndex, @nextPart, @displayPoints[@displayPoints.length - 1].position
      @_calculateControlPoints @displayPoints.length - 2, @displayPoints.length - 1
  
  projectToLine: (pointIndex, straightLine, target) ->
    _point.copy @line.getPoint pointIndex
    straightLine.line2.closestPointToPoint _point, false, target
    
  _getPointSegment: (index) ->
    if @isClosed then @pointSegments[_.modulo index, @pointSegments.length] else @pointSegments[index]
    
  _getEdgeSegment: (index) ->
    return null unless @isClosed or @startSegmentIndex <= index <= @endSegmentIndex

    @line.getEdgeSegment index
