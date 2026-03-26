AB = Artificial.Babel
PAA = PixelArtAcademy
RA = PAA.Practice.ReadabilityAnalysis

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.ReadabilityAnalysis extends PAA.PixelPad.Apps.Drawing.Editor.Desktop.ReadabilityAnalysis
  @register @id()
  
  _regionRecognitionResult: (region) ->
    return unless region.labels
    
    labelString = AB.Rules.English.addIndefinitePronoun region.targetLabel
    
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
    
    # Use the best other list to determine which other labels this drawing
    # could be confused with, if their (weighted) percentage is above 50%.
    if bestOtherLabelProbabilities.length >= 2 and bestOtherLabelProbabilities[1].probabilityPercentage > 50
      unrecognizableExplanation = "This could maybe be confused with #{AB.Rules.English.addIndefinitePronoun bestOtherLabelProbabilities[0].label} or #{AB.Rules.English.addIndefinitePronoun bestOtherLabelProbabilities[1].label}."
      
    else if bestOtherLabelProbabilities.length >= 1 and bestOtherLabelProbabilities[0].probabilityPercentage > 50
      unrecognizableExplanation = "This could maybe be confused with #{AB.Rules.English.addIndefinitePronoun bestOtherLabelProbabilities[0].label}."
      
    else
      unrecognizableExplanation = "Draw more details to distinguish the subject."
    
    # Create recognition results.
    perfectResult = passes: true, summary: "Perfect", explanation: "There is no doubt this is #{labelString}."
    greatResult = passes: true, summary: "Great", explanation: "This is easily recognized as #{labelString}."
    goodResult = passes: true, summary: "Good", explanation: "This is likely #{labelString}."
    adequateResult = passes: true, summary: "Adequate", explanation: "This could be #{labelString}."
    poorResult = passes: false, summary: "Poor", explanation: unrecognizableExplanation
    problematicResult = passes: false, summary: "Problematic", explanation: unrecognizableExplanation
    
    # If both classifiers recognize the subject, this gives good–perfect results.
    if targetProbabilityPercentages.symbolic >= 95 and targetProbabilityPercentages.realistic >= 95
      return perfectResult
    
    else if targetProbabilityPercentages.symbolic >= 85 and targetProbabilityPercentages.realistic >= 85
      return greatResult
    
    else if targetProbabilityPercentages.symbolic >= 75 and targetProbabilityPercentages.realistic >= 75
      return goodResult
    
    # If both classifiers fail to recognize the subject, we do not pass recognition.
    else if targetProbabilityPercentages.symbolic < 10 and targetProbabilityPercentages.realistic < 10
      return problematicResult
      
    # If one of the classifiers doesn't recognize the subject at all
    # (under 1%), only pass in case symbolic is really confident.
    else if targetProbabilityPercentages.symbolic < 1 or targetProbabilityPercentages.realistic < 1
      if targetProbabilityPercentages.symbolic >= 95
        return adequateResult
        
      else
        return poorResult
      
    # If the realistic classifier can at least vaguely recognize the
    # subject, the symbolic one can give adequate–good results .
    if targetProbabilityPercentages.realistic > 10
      if targetProbabilityPercentages.symbolic >= 95
        return goodResult
        
      else if targetProbabilityPercentages.symbolic >= 75
        return adequateResult
    
    # None of the classifiers recognized the subject confidently (75% or more),
    # so see if one of them has a big enough margin to the best of the other labels.
    symbolicDifference = targetProbabilityPercentages.symbolic - (highestOtherLabelProbabilities.symbolic?.probabilityPercentage or 0)
    realisticDifference = targetProbabilityPercentages.realistic - (highestOtherLabelProbabilities.realistic?.probabilityPercentage or 0)
    highestDifference = Math.max symbolicDifference, realisticDifference
    
    # Big enough margin gives adequate–good results.
    if highestDifference >= 50
      return goodResult
      
    else if highestDifference >= 25
      return adequateResult
      
    # If both classifiers recognized the subject as the most probable, this is good.
    if symbolicDifference > 0 and realisticDifference > 0
      return goodResult

    # If at least one of the classifiers recognized the subject, this is adequate.
    else if symbolicDifference > 0 or realisticDifference > 0
      return adequateResult
      
    # None of the classifiers recognized the subject as the most likely, so don't pass recognition.
    poorResult
