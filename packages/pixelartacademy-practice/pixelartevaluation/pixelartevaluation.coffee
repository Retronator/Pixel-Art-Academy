PAA = PixelArtAcademy

class PAA.Practice.PixelArtEvaluation
  # score: float between 0 and 1 for the final average score
  # consistentLineWidth:
  #   score: float between 0 and 1 with this criterion evaluation
  # evenDiagonals
  #   score: float between 0 and 1 with this criterion's weighted average
  #   segmentLengths:
  #     score: float between 0 and 1 with this criterion evaluation
  #     linePartCounts: object with counts of line parts with a certain segment lengths type
  #       even, alternating, broken: how many line parts has this type
  #   endSegments:
  #     score: float between 0 and 1 with this criterion evaluation
  #     linePartCounts: object with counts of line parts with a certain end segments type
  #       matching, shorter: how many line parts has this type
  # smoothCurves: objects with different criteria evaluations
  #   score: float between 0 and 1 with this criterion evaluation

  @Criteria =
    ConsistentLineWidth: 'ConsistentLineWidth'
    EvenDiagonals: 'EvenDiagonals'
    SmoothCurves: 'SmoothCurves'

  @Subcriteria =
    EvenDiagonals:
      SegmentLengths: 'SegmentLengths'
      EndSegments: 'EndSegments'
  
  @SubcriteriaWeights =
    EvenDiagonals:
      SegmentLengths: 0.75
      EndSegments: 0.25
  
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
    
  constructor: (@bitmap) ->
    @layers = []
    
    @_evaluationDependency = new Tracker.Dependency

    # Initialize by updating the full area of the bitmap.
    Tracker.nonreactive =>
      @_updateArea layerIndex for layerIndex in [0...@bitmap.layers.length]
    
    # Subscribe to changes.
    LOI.Assets.Bitmap.versionedDocuments.operationsExecuted.addHandler @, @onOperationsExecuted

  destroy: ->
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
    
    if pixelArtEvaluationProperty.evenDiagonals
      # Compute evaluation if needed.
      unless @_evaluation.evenDiagonals
        @_evaluation.evenDiagonals =
          segmentLengths:
            score: 0
            linePartCounts:
              even: 0
              alternating: 0
              broken: 0
          endSegments:
            score: 0
            linePartCounts:
              matching: 0
              shorter: 0
        
        totalWeight = 0
        
        for layer in @layers
          for line in layer.lines
            for linePart in line.parts when linePart instanceof @constructor.Line.Part.StraightLine
              linePartEvaluation = linePart.evaluate()
              weight = Math.sqrt linePart.points.length
              
              for subcriterion of @constructor.Subcriteria.EvenDiagonals
                subcriterionProperty = _.lowerFirst subcriterion
                @_evaluation.evenDiagonals[subcriterionProperty].score += linePartEvaluation[subcriterionProperty].score * weight
                @_evaluation.evenDiagonals[subcriterionProperty].linePartCounts[_.lowerFirst linePartEvaluation[subcriterionProperty].type]++
              
              totalWeight += weight
          
        for subcriterion of @constructor.Subcriteria.EvenDiagonals
          subcriterionProperty = _.lowerFirst subcriterion
          
          if totalWeight
            @_evaluation.evenDiagonals[subcriterionProperty].score /= totalWeight
            
          else
            # There were no lines to be evaluated, so the category doesn't have a meaning.
            @_evaluation.evenDiagonals[subcriterionProperty].score = null
      
      evaluation.evenDiagonals = score: 0
      
      # Choose only enabled subcriteria.
      totalWeight = 0
      
      subcriteriaInfo = for subcriterion of @constructor.Subcriteria.EvenDiagonals
        subcriterionProperty = _.lowerFirst subcriterion
        continue unless pixelArtEvaluationProperty.evenDiagonals[subcriterionProperty]
        
        weight = if @_evaluation.evenDiagonals[subcriterionProperty].score? then @constructor.SubcriteriaWeights.EvenDiagonals[subcriterion] else 0
        totalWeight += weight
        
        property: subcriterionProperty
        score: @_evaluation.evenDiagonals[subcriterionProperty].score or 0
        weight: weight
        
      for subcriterionInfo in subcriteriaInfo
        evaluation.evenDiagonals[subcriterionInfo.property] = @_evaluation.evenDiagonals[subcriterionInfo.property]
        evaluation.evenDiagonals.score += subcriterionInfo.score * subcriterionInfo.weight / totalWeight if totalWeight
      
      if totalWeight
        finalScore += evaluation.evenDiagonals.score
        criteriaCount++
        
      else
        evaluation.evenDiagonals.score = null
      
    finalScore /= criteriaCount if criteriaCount
    
    evaluation.score = if criteriaCount then finalScore else null
    
    evaluation
    
  onOperationsExecuted: (document, operations, changedFields) ->
    return unless document._id is @bitmap._id
    
    for operation in operations when operation instanceof LOI.Assets.Bitmap.Operations.ChangePixels
      @_updateArea operation.layerAddress[0], operation.bounds
