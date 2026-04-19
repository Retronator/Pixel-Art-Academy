AB = Artificial.Babel
PAA = PixelArtAcademy
RA = PAA.Practice.ReadabilityAnalysis

PAA.PixelPad.Apps.Drawing.Editor.Desktop.ReadabilityAnalysis::_regionRecognitionResult = (region, bounds) ->
  return unless region.labels
  
  labelString = AB.Rules.English.addIndefinitePronoun region.targetLabel
  
  # Create recognition results.
  perfectResult = passes: true, summary: "Perfect", explanation: "There is no doubt this is #{labelString}."
  greatResult = passes: true, summary: "Great", explanation: "This is easily recognized as #{labelString}."
  goodResult = passes: true, summary: "Good", explanation: "This is likely #{labelString}."
  adequateResult = passes: true, summary: "Adequate", explanation: "This could be #{labelString}."
  
  # For results that don't pass, try to create some useful feedback, based on probabilities of other labels.
  
  # Determine target label probability, by classifier.
  targetProbabilityPercentages = {}
  
  for classifierName, labelProbabilities of region.labels
    targetProbabilityPercentage = _.find labelProbabilities, (labelProbability) => labelProbability.label is region.targetLabel
    targetProbabilityPercentages[classifierName] = targetProbabilityPercentage?.probabilityPercentage or 0
    
  # Determine highest probability from other labels, by classifier.
  highestOtherLabelProbabilities = {}
  for classifierName, labelProbabilities of region.labels
    highestOtherLabelProbabilities[classifierName] = _.find labelProbabilities, (labelProbability) => labelProbability.label isnt region.targetLabel
    
  # Determine joint probability of other labels (with realistic having 60% value compared to the symbolic).
  bestOtherLabelProbabilities = [region.labels.symbolic...]
  
  for labelProbability in region.labels.realistic
    bestOtherLabelProbabilities.push
      label: labelProbability.label
      probabilityPercentage: labelProbability.probabilityPercentage * 0.6
  
  # Sort from best to worst.
  bestOtherLabelProbabilities.sort (a, b) => b.probabilityPercentage - a.probabilityPercentage
  
  # Remove the worst of the symbolic/realistic pair.
  checkIndex = 0
  while checkIndex < bestOtherLabelProbabilities.length
    checkLabel = bestOtherLabelProbabilities[checkIndex].label
    otherIndex = _.findIndex bestOtherLabelProbabilities[checkIndex + 1...], (labelProbability) => labelProbability.label is checkLabel
    bestOtherLabelProbabilities.splice checkIndex + 1 + otherIndex, 1 if otherIndex >= 0
    checkIndex++
  
  # Remove the target labels.
  _.remove bestOtherLabelProbabilities, (labelProbability) => labelProbability.label is region.targetLabel
  
  # Certain thresholds depend on the size of the drawing since
  # smaller drawings are harder to draw and should be more forgiving.
  drawingSize = Math.min bounds.width, bounds.height
  clampedDrawingSize = _.clamp drawingSize, 8, 16
  drawingSizeWeight = THREE.MathUtils.inverseLerp 8,16, clampedDrawingSize
  
  adaptiveThreshold = (threshold8, threshold16) => THREE.MathUtils.lerp threshold8, threshold16, drawingSizeWeight
  
  # Use the best other list to determine which other labels this drawing could be confused with, if their (weighted)
  # percentage is high enough. At smaller sizes, we want the system to have to be more confident since it's much
  # easier to misinterpret things.
  confidenceThreshold = adaptiveThreshold 90, 50
  
  if bestOtherLabelProbabilities.length >= 2 and bestOtherLabelProbabilities[1].probabilityPercentage > confidenceThreshold
    unrecognizableExplanation = "This could maybe be confused with #{AB.Rules.English.addIndefinitePronoun bestOtherLabelProbabilities[0].label} or #{AB.Rules.English.addIndefinitePronoun bestOtherLabelProbabilities[1].label}."
    
  else if bestOtherLabelProbabilities.length >= 1 and bestOtherLabelProbabilities[0].probabilityPercentage > confidenceThreshold
    unrecognizableExplanation = "This could maybe be confused with #{AB.Rules.English.addIndefinitePronoun bestOtherLabelProbabilities[0].label}."
    
  else
    unrecognizableExplanation = "Draw more details to distinguish the subject."
    unconfidentResult = true

  if drawingSize >= 16 or not unconfidentResult
    poorResult = passes: false, summary: "Poor", explanation: unrecognizableExplanation
    problematicResult = passes: false, summary: "Problematic", explanation: unrecognizableExplanation
  
  else
    poorResult = passes: false, summary: "Inconclusive", explanation: "I'm having trouble distinguish the subject at this small size."
    problematicResult = poorResult
      
  bothFailingThreshold = adaptiveThreshold 1, 10
  
  # If both classifiers recognize the subject, this gives good–perfect results.
  if targetProbabilityPercentages.symbolic >= 95 and targetProbabilityPercentages.realistic >= 95
    console.log "Perfect probability:", targetProbabilityPercentages.symbolic, targetProbabilityPercentages.realistic, ">= 95" if @debug
    return perfectResult
  
  else if targetProbabilityPercentages.symbolic >= 85 and targetProbabilityPercentages.realistic >= 85
    console.log "Great probability:", targetProbabilityPercentages.symbolic, targetProbabilityPercentages.realistic, ">= 85" if @debug
    return greatResult
  
  else if targetProbabilityPercentages.symbolic >= 75 and targetProbabilityPercentages.realistic >= 75
    console.log "Good probability:", targetProbabilityPercentages.symbolic, targetProbabilityPercentages.realistic, ">= 75" if @debug
    return goodResult
  
  # If both classifiers fail to recognize the subject, we do not pass recognition.
  else if targetProbabilityPercentages.symbolic < bothFailingThreshold and targetProbabilityPercentages.realistic < bothFailingThreshold
    console.log "No classifier sees the subject." if @debug
    return problematicResult
    
  # If the realistic classifier can at least vaguely recognize the subject, the symbolic one can give good results.
  if targetProbabilityPercentages.realistic >= 10 and targetProbabilityPercentages.symbolic >= adaptiveThreshold 50, 95
    console.log "Realistic poor, but symbolic good:", targetProbabilityPercentages.symbolic, targetProbabilityPercentages.realistic, ">=", adaptiveThreshold 50, 95 if @debug
    return goodResult
    
  # None of the classifiers recognized the subject confidently (75% or more),
  # so see if one of them has a big enough margin to the best of the other labels.
  symbolicDifference = targetProbabilityPercentages.symbolic - (highestOtherLabelProbabilities.symbolic?.probabilityPercentage or 0)
  realisticDifference = targetProbabilityPercentages.realistic - (highestOtherLabelProbabilities.realistic?.probabilityPercentage or 0)
  highestDifference = Math.max symbolicDifference, realisticDifference
  
  # If both classifiers recognized the subject as the most probable, this is good.
  if symbolicDifference > 0 and realisticDifference > 0
    console.log "1st place in both symbolic and realistic:", symbolicDifference, realisticDifference if @debug
    return goodResult
  
  # Big enough margin gives adequate–good results.
  if highestDifference >= adaptiveThreshold 20, 50
    console.log "1st place difference is big:", symbolicDifference, realisticDifference, ">=", adaptiveThreshold 20, 50 if @debug
    return goodResult
    
  else if highestDifference >= adaptiveThreshold 10, 25
    console.log "1st place difference is medium:", symbolicDifference, realisticDifference, ">=", adaptiveThreshold 10, 25 if @debug
    return adequateResult

  # If at least one of the classifiers recognized the subject, this is adequate.
  else if symbolicDifference > 0 or realisticDifference > 0
    console.log "1st place difference exists:", symbolicDifference, realisticDifference, ">= 0" if @debug
    return adequateResult
  
  # If the realistic classifier can recognize the subject, the symbolic one can give adequate results.
  if targetProbabilityPercentages.realistic >= 1 and targetProbabilityPercentages.symbolic >= adaptiveThreshold 30, 75
    console.log "Realistic exists, but symbolic is enough:", targetProbabilityPercentages.symbolic, targetProbabilityPercentages.realistic, adaptiveThreshold 30, 75 if @debug
    return adequateResult
    
  # At small sizes, if at least one of the classifiers shows any probability for the target, this is adequate. We lower
  # the threshold as the probabilities become more specific, meaning, we need 2% if only 2 things are recognized, 3% if
  # 3, 4% if 4, etc.
  if targetProbabilityPercentages.symbolic >= adaptiveThreshold region.labels.symbolic.length, 50
    console.log "Symbolic is probable enough:", targetProbabilityPercentages.symbolic, ">=", adaptiveThreshold region.labels.symbolic.length, 50 if @debug
    return adequateResult
  
  if targetProbabilityPercentages.realistic >= adaptiveThreshold region.labels.realistic.length, 50
    console.log "Realistic is probable enough:", targetProbabilityPercentages.realistic, ">=", adaptiveThreshold region.labels.realistic.length, 50 if @debug
    return adequateResult
    
  # At small sizes, if the target is in one of the top spots, that is adequate.
  # Top 4 spots when 5 things are recognized, top 2 stops when 10, top 1 when 15.
  hasTopPlacement = (labels) =>
    minimumPlace8 = Math.max 1, Math.floor 4 - labels.length / 5
    targetPlacementIndex = _.findIndex labels, (labelProbability) => labelProbability.label is region.targetLabel
    return unless targetPlacementIndex >= 0
    
    targetPlacement = targetPlacementIndex + 1
    return unless targetPlacement <= adaptiveThreshold minimumPlace8, 1
    
    placement: targetPlacement, required: adaptiveThreshold minimumPlace8, 1
  
  if symbolicTopPlacement = hasTopPlacement region.labels.symbolic
    console.log "Realistic placement in top", symbolicTopPlacement.required, "at", symbolicTopPlacement.placement if @debug
    return adequateResult
  
  if realisticTopPlacement = hasTopPlacement region.labels.realistic
    console.log "Realistic placement in top", realisticTopPlacement.required, "at", realisticTopPlacement.placement if @debug
    return adequateResult
  
  # None of the classifiers recognized the subject as the most likely, so don't pass recognition.
  console.log "Probability is not high enough for positive classification.", targetProbabilityPercentages.symbolic, "<", adaptiveThreshold(region.labels.symbolic.length, 50), targetProbabilityPercentages.realistic, "<", adaptiveThreshold(region.labels.realistic.length, 50) if @debug

  poorResult
