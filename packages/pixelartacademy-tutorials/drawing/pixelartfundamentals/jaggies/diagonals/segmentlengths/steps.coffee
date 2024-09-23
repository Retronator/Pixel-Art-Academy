LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
PAE = PAA.Practice.PixelArtEvaluation
StraightLine = PAE.Line.Part.StraightLine
SegmentLengths = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.SegmentLengths

class SegmentLengths.Steps
  class @DrawLine extends TutorialBitmap.PixelsWithPathsStep
    completed: ->
      return unless super arguments...
      
      # Wait until the line has stopped drawing, otherwise adding pixel art
      # evaluation properties will happen in-between the stroke and get lost.
      not @tutorialBitmap.bitmap().partialAction
    
  class @OpenEvaluationPaper extends PAA.Tutorials.Drawing.PixelArtFundamentals.OpenEvaluationPaper
    activate: ->
      super arguments...
      
      bitmap = @tutorialBitmap.bitmap()
      
      pixelArtEvaluation =
        allowedCriteria: [PAE.Criteria.EvenDiagonals]
        evenDiagonals:
          segmentLengths: {}
      
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.constructor.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
      
      bitmap.executeAction updatePropertyAction
      
  class @HoverOverTheDiagonals extends TutorialBitmap.EphemeralStep
    constructor: ->
      super arguments...
      
      @lineStartYsHoveredOver = new ReactiveField []
      
    reset: ->
      super arguments...
      
      @lineStartYsHoveredOver []
      
    completed: ->
      return true if super arguments...
      
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluationView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      return unless pixelArtEvaluationView.activeCriterion() is PAE.Criteria.EvenDiagonals
      return unless hoveredPixel = pixelArtEvaluationView.hoveredPixel()
      
      pixelArtEvaluation = pixelArtEvaluationView.pixelArtEvaluation()
      return unless hoveredLine = pixelArtEvaluation.getLinesAt(hoveredPixel.x, hoveredPixel.y)[0]
      
      startY = hoveredLine.pixels[0].y
      lineStartYsHoveredOver = @lineStartYsHoveredOver()
      
      unless startY in lineStartYsHoveredOver
        lineStartYsHoveredOver.push startY
        @lineStartYsHoveredOver lineStartYsHoveredOver
        
        if lineStartYsHoveredOver.length is 3
          @solve()
          return true
      
      false
      
  class @LineEvaluationStep extends TutorialBitmap.PathStep
    getLineEvaluation: ->
      return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()
      
      linePartsAtCorners = for cornersForPart in @paths[0].cornersOfParts
        for corner in cornersForPart
          pixelArtEvaluation.getLinePartsAt corner.x, corner.y
      
      linePartsAtCorners = _.flatten linePartsAtCorners
      linePartsAtAllCorners = _.intersection linePartsAtCorners...
      
      return unless linePart = linePartsAtAllCorners[0]
      return unless linePart instanceof StraightLine
      
      linePart.evaluate()
      
  class @LineOfType extends @LineEvaluationStep
    @type: -> throw new AE.NotImplementedException "A line of type step must provide the type needed for completion."
    
    # Prevent new doubles to backtrack steps.
    @preserveCompleted: -> true
    
    completed: ->
      # Make sure no doubles are in the lines.
      return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()
      for line in pixelArtEvaluation.layers[0].lines
        # The line must not have any doubles.
        lineEvaluation = line.evaluate()
        return false if lineEvaluation.doubles.count
      
      # Ensure ideal results by also requiring matching ends.
      return unless lineEvaluation = @getLineEvaluation()
      return unless lineEvaluation.endSegments.type is StraightLine.EndSegments.Matching

      lineEvaluation.segmentLengths.type is @constructor.type()
  
  class @AlternatingLine extends @LineOfType
    @type: -> StraightLine.SegmentLengths.Alternating

  class @EvenLine extends @LineOfType
    @type: -> StraightLine.SegmentLengths.Even
