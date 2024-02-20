PAA = PixelArtAcademy

class PAA.Practice.PixelArtEvaluation
  # score: float between 0 and 1 for the final average score
  # pixelPerfectLines:
  #   score: float between 0 and 1 with this criterion evaluation
  #   doubles:
  #     score: float between 0 and 1 with this criterion evaluation
  #     count: how many pixels lie on axis-aligned side-steps or wide lines
  #   corners:
  #     score: float between 0 and 1 with this criterion evaluation
  #     count: how many pixels have two or more direct neighbors
  # consistentLineWidth:
  #   score: float between 0 and 1 with this criterion evaluation
  # evenDiagonals
  #   score: float between 0 and 1 with this criterion's weighted average
  #   segmentLengths:
  #     score: float between 0 and 1 with this criterion evaluation
  #     counts: object with counts of line parts with a certain segment lengths type
  #       even, alternating, broken: how many line parts has this type
  #   endSegments:
  #     score: float between 0 and 1 with this criterion evaluation
  #     counts: object with counts of line parts with a certain end segments type
  #       matching, shorter: how many line parts has this type
  # smoothCurves: objects with different criteria evaluations
  #   score: float between 0 and 1 with this criterion evaluation
  #   abruptSegmentLengthChanges:
  #     score: float between 0 and 1 with this criterion evaluation
  #     counts: object with counts of how many segment length changes are abrupt for each severity
  #       minor, major: how many segment length changes of this severity there are
  #   straightParts:
  #     score: float between 0 and 1 with this criterion evaluation
  #     counts: object with counts of line parts with a certain positioning in the curve
  #       middle, end: how many line parts of this type there are
  #   inflectionPoints:
  #     score: float between 0 and 1 with this criterion evaluation
  #     counts: object with counts of how many inflection points appear on curves
  #       isolated, sparse, dense: how many inflection points of this type there are

  @Criteria =
    PixelPerfectLines: 'PixelPerfectLines'
    ConsistentLineWidth: 'ConsistentLineWidth'
    EvenDiagonals: 'EvenDiagonals'
    SmoothCurves: 'SmoothCurves'

  @Subcriteria =
    PixelPerfectLines:
      Doubles: 'Doubles'
      Corners: 'Corners'
    EvenDiagonals:
      SegmentLengths: 'SegmentLengths'
      EndSegments: 'EndSegments'
    SmoothCurves:
      AbruptSegmentLengthChanges: 'AbruptSegmentLengthChanges'
      StraightParts: 'StraightParts'
      InflectionPoints: 'InflectionPoints'
  
  @SubcriteriaWeights =
    PixelPerfectLines:
      Doubles: 0.75
      Corners: 0.25
    EvenDiagonals:
      SegmentLengths: 0.75
      EndSegments: 0.25
    SmoothCurves:
      AbruptSegmentLengthChanges: 0.34
      StraightParts: 0.33
      InflectionPoints: 0.33
      
  @_lastId = 0

  @nextId: ->
    @_lastId++
    @_lastId
  
  @getLetterGrade = (score, plusMinus = false) ->
    scoreOutOf10 = score * 10
    
    letterBracket = Math.min 9, Math.floor scoreOutOf10
    letterBracket = 4 if letterBracket < 6
    
    letterGrade = String.fromCharCode(65 + 9 - letterBracket)
    
    if plusMinus and letterBracket > 4
      scoreRemainderOutOf100 = Math.round (scoreOutOf10 - letterBracket) * 10
      
      letterGrade += '-' if scoreRemainderOutOf100 < 3
      letterGrade += '+' if scoreRemainderOutOf100 >= 7
    
    letterGrade
    
  constructor: (@bitmap, @options = {}) ->
    @layers = []
    
    @_evaluationDependency = new Tracker.Dependency

    # Initialize by updating the full area of the bitmap.
    Tracker.nonreactive =>
      @_updateArea layerIndex for layerIndex in [0...@bitmap.layers.length]
    
    # Subscribe to changes.
    if @options.partialUpdates
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.addHandler @, @onOperationExecuted
      
    else
      LOI.Assets.Bitmap.versionedDocuments.operationsExecuted.addHandler @, @onOperationsExecuted

  destroy: ->
    if @options.partialUpdates
      LOI.Assets.Bitmap.versionedDocuments.operationExecuted.removeHandler @, @onOperationsExecuted
      
    else
      LOI.Assets.Bitmap.versionedDocuments.operationsExecuted.removeHandler @, @onOperationsExecuted
    
  depend: ->
    @_evaluationDependency.depend()
    
  getLinesAt: (x, y) ->
    lines = for layer in @layers
      layer.getLinesAt x, y
    
    _.flatten lines
    
  getLinesBetween: (points...) ->
    lines = for layer in @layers
      layer.getLinesBetween points...
    
    _.flatten lines
    
  getLinePartsAt: (x, y) ->
    lineParts = for layer in @layers
      layer.getLinePartsAt x, y
    
    _.flatten lineParts
  
  getLinePartsBetween: (points...) ->
    lineParts = for layer in @layers
      layer.getLinePartsBetween points...
    
    _.flatten lineParts
    
  _updateArea: (layerIndex, bounds) ->
    if @layers[layerIndex]
      # Update just the desired bounds.
      @layers[layerIndex].updateArea bounds
      
    else
      # Create and update the whole layer when it's added.
      @layers[layerIndex] = new @constructor.Layer @, [layerIndex]
      @layers[layerIndex].updateArea()
    
    @_evaluation = {}
    @_evaluationDependency.changed()
    
  evaluate: (pixelArtEvaluationProperty) ->
    @_evaluationDependency.depend()
    
    evaluation = {}

    finalScore = 0
    criteriaCount = 0
    
    if pixelArtEvaluationProperty.pixelPerfectLines
      # Compute evaluation if needed.
      unless @_evaluation.pixelPerfectLines
        @_evaluation.pixelPerfectLines =
          doubles:
            score: 0
            count: 0
          corners:
            score: 0
            count: 0
            
        # Compute average score, weighted by line length.
        totalWeight = 0
        
        doubles = []

        for layer in @layers
          for line in layer.lines
            lineEvaluation = line.evaluate()
            
            # We collect doubles separately so we can count them all at once to avoid them accounted multiple times.
            for pixel in lineEvaluation.doubles.pixels
              doubles.push pixel unless pixel in doubles
            
            # We use the square root of the length so that long lines can't hugely overtake the short ones.
            weight = Math.sqrt line.points.length
            
            for subcriterion of @constructor.Subcriteria.PixelPerfectLines
              subcriterionProperty = _.lowerFirst subcriterion
              @_evaluation.pixelPerfectLines[subcriterionProperty].score += lineEvaluation[subcriterionProperty].score * weight
              @_evaluation.pixelPerfectLines[subcriterionProperty].count += lineEvaluation[subcriterionProperty].count
            
            totalWeight += weight
            
        @_evaluation.pixelPerfectLines.doubles.count = doubles.length
        
        for subcriterion of @constructor.Subcriteria.PixelPerfectLines
          subcriterionProperty = _.lowerFirst subcriterion
          
          if totalWeight
            @_evaluation.pixelPerfectLines[subcriterionProperty].score /= totalWeight
            
          else
            # There were no lines to be evaluated, so the category doesn't have a meaning.
            @_evaluation.pixelPerfectLines[subcriterionProperty].score = null
    
      evaluation.pixelPerfectLines = @_calculateWeightedEvaluation @constructor.Subcriteria.PixelPerfectLines, @constructor.SubcriteriaWeights.PixelPerfectLines, pixelArtEvaluationProperty.pixelPerfectLines, @_evaluation.pixelPerfectLines
      
      if evaluation.pixelPerfectLines.score
        finalScore += evaluation.pixelPerfectLines.score
        criteriaCount++
        
    if pixelArtEvaluationProperty.evenDiagonals
      # Compute evaluation if needed.
      unless @_evaluation.evenDiagonals
        @_evaluation.evenDiagonals =
          segmentLengths:
            score: 0
            counts:
              even: 0
              alternating: 0
              broken: 0
          endSegments:
            score: 0
            counts:
              matching: 0
              shorter: 0
        
        totalWeight = 0
        
        for layer in @layers
          for line in layer.lines
            for linePart in line.parts when linePart instanceof @constructor.Line.Part.StraightLine
              # Count only diagonals.
              linePartEvaluation = linePart.evaluate()
              continue if linePartEvaluation.type is @constructor.Line.Part.StraightLine.Type.AxisAligned
              
              weight = Math.sqrt linePart.points.length
              
              for subcriterion of @constructor.Subcriteria.EvenDiagonals
                subcriterionProperty = _.lowerFirst subcriterion
                @_evaluation.evenDiagonals[subcriterionProperty].score += linePartEvaluation[subcriterionProperty].score * weight
                @_evaluation.evenDiagonals[subcriterionProperty].counts[_.lowerFirst linePartEvaluation[subcriterionProperty].type]++
              
              totalWeight += weight
          
        for subcriterion of @constructor.Subcriteria.EvenDiagonals
          subcriterionProperty = _.lowerFirst subcriterion
          
          if totalWeight
            @_evaluation.evenDiagonals[subcriterionProperty].score /= totalWeight
            
          else
            # There were no lines to be evaluated, so the category doesn't have a meaning.
            @_evaluation.evenDiagonals[subcriterionProperty].score = null
      
      evaluation.evenDiagonals = @_calculateWeightedEvaluation @constructor.Subcriteria.EvenDiagonals, @constructor.SubcriteriaWeights.EvenDiagonals, pixelArtEvaluationProperty.evenDiagonals, @_evaluation.evenDiagonals
      
      if evaluation.evenDiagonals.score
        finalScore += evaluation.evenDiagonals.score
        criteriaCount++
      
    if pixelArtEvaluationProperty.smoothCurves
      # Compute evaluation if needed.
      unless @_evaluation.smoothCurves
        @_evaluation.smoothCurves =
          abruptSegmentLengthChanges:
            score: 0
            counts:
              minor: 0
              major: 0
          straightParts:
            score: 0
            counts:
              middle: 0
              end: 0
          inflectionPoints:
            score: 0
            counts:
              isolated: 0
              sparse: 0
              dense: 0
            
        # Compute average score, weighted by line length.
        totalWeight = 0
        
        for layer in @layers
          for line in layer.lines
            lineEvaluation = line.evaluate()
            continue unless lineEvaluation.curveSmoothness
            
            # We use the square root of the length so that long lines can't hugely overtake the short ones.
            weight = Math.sqrt line.points.length
            
            for subcriterion of @constructor.Subcriteria.SmoothCurves
              subcriterionProperty = _.lowerFirst subcriterion
              curveSmoothness = lineEvaluation.curveSmoothness[subcriterionProperty]
              
              @_evaluation.smoothCurves[subcriterionProperty].score += curveSmoothness.score * weight
              
              for category, linePartCount of curveSmoothness.counts
                @_evaluation.smoothCurves[subcriterionProperty].counts[category] += linePartCount
              
            totalWeight += weight
        
        for subcriterion of @constructor.Subcriteria.SmoothCurves
          subcriterionProperty = _.lowerFirst subcriterion
          
          if totalWeight
            @_evaluation.smoothCurves[subcriterionProperty].score /= totalWeight
            
          else
            # There were no curves to be evaluated, so the category doesn't have a meaning.
            @_evaluation.smoothCurves[subcriterionProperty].score = null
    
      evaluation.smoothCurves = @_calculateWeightedEvaluation @constructor.Subcriteria.SmoothCurves, @constructor.SubcriteriaWeights.SmoothCurves, pixelArtEvaluationProperty.smoothCurves, @_evaluation.smoothCurves
      
      if evaluation.smoothCurves.score?
        finalScore += evaluation.smoothCurves.score
        criteriaCount++
        
    finalScore /= criteriaCount if criteriaCount
    
    evaluation.score = if criteriaCount then finalScore else null
    
    evaluation
    
  _calculateWeightedEvaluation: (subcriteria, subcriteriaWeights, enabledProperties, evaluation) ->
    weightedEvaluation = score: 0
    
    # Choose only enabled subcriteria.
    totalWeight = 0
    
    subcriteriaInfo = for subcriterion of subcriteria
      subcriterionProperty = _.lowerFirst subcriterion
      continue unless enabledProperties[subcriterionProperty]
      
      weight = if evaluation[subcriterionProperty].score? then subcriteriaWeights[subcriterion] else 0
      totalWeight += weight
      
      property: subcriterionProperty
      score: evaluation[subcriterionProperty].score or 0
      weight: weight
    
    for subcriterionInfo in subcriteriaInfo
      weightedEvaluation[subcriterionInfo.property] = evaluation[subcriterionInfo.property]
      weightedEvaluation.score += subcriterionInfo.score * subcriterionInfo.weight / totalWeight if totalWeight
    
    weightedEvaluation.score = null unless totalWeight
    
    weightedEvaluation
  
  onOperationExecuted: (document, operation, changedFields) ->
    return unless document._id is @bitmap._id
    return unless operation instanceof LOI.Assets.Bitmap.Operations.ChangePixels

    @_updateArea operation.layerAddress[0], operation.bounds
    
  onOperationsExecuted: (document, operations, changedFields) ->
    return unless document._id is @bitmap._id
    
    for operation in operations when operation instanceof LOI.Assets.Bitmap.Operations.ChangePixels
      @_updateArea operation.layerAddress[0], operation.bounds
