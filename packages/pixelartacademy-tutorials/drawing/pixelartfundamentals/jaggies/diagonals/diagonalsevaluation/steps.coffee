LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
PAE = PAA.Practice.PixelArtEvaluation
StraightLine = PAE.Line.Part.StraightLine
DiagonalsEvaluation = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.DiagonalsEvaluation

class DiagonalsEvaluation.Steps
  class @OpenEvaluationPaper extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      drawingEditor = @getEditor()
      pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active()
    
  class @ClickOnEvenDiagonals extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.activeCriterion() is PAE.Criteria.EvenDiagonals
    
  class @HoverOverTheDiagonal extends TutorialBitmap.EphemeralStep
    @timeToHover = 1.5
    
    constructor: ->
      super arguments...
      
      @timeHovered = 0
      
    completed: ->
      return true if super arguments...
      
      return @stopCountingTime() unless drawingEditor = @getEditor()
      return @stopCountingTime() unless pixelArtEvaluationView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      return @stopCountingTime() unless hoveredPixel = pixelArtEvaluationView.hoveredPixel()
      
      pixelArtEvaluation = pixelArtEvaluationView.pixelArtEvaluation()
      return @stopCountingTime() unless pixelArtEvaluation.getLinePartsAt(hoveredPixel.x, hoveredPixel.y).length
      
      @countTime()
      
      # We return false since we'll complete this step by solving it which will resolve in the base completed.
      false
      
    stopCountingTime: ->
      @timeHovered = 0
      Meteor.clearTimeout @_countTimeout

    countTime: ->
      Meteor.clearTimeout @_countTimeout
      @_countTimeout = Meteor.setTimeout =>
        @timeHovered += 0.1
        
        if @timeHovered >= @constructor.timeToHover
          @solve()
          
        else
          @countTime()
      ,
        100
      
  class @LineEvaluationStep extends TutorialBitmap.PathStep
    @drawHintsAfterCompleted: -> false
  
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
    
    completed: ->
      # Ensure ideal results by also requiring matching ends.
      return unless lineEvaluation = @getLineEvaluation()
      return unless lineEvaluation.endSegments.type is StraightLine.EndSegments.Matching

      lineEvaluation.segmentLengths.type is @constructor.type()
  
  class @AlternatingLine extends @LineOfType
    @type: -> StraightLine.SegmentLengths.Alternating
  
  class @CloseEvaluationPaper extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      active = pixelArtEvaluation.active()
      
      return true if @_wasActive and not active
      
      @_wasActive = active
      
      false
      
  class @EnableEndSegments extends @OpenEvaluationPaper
    activate: ->
      super arguments...
      
      # Execute action with a delay so that the current stroke action has time to complete and the pixel art evaluation
      # gets updated. Otherwise the pixel art evaluation property would get overwritten with old data. Additionally,
      # this makes it more obvious to the user that a new part of the evaluation paper was unlocked.
      Meteor.setTimeout =>
        bitmap = @tutorialBitmap.bitmap()
        
        pixelArtEvaluation = EJSON.clone bitmap.properties.pixelArtEvaluation
        pixelArtEvaluation.evenDiagonals.endSegments = {}
        
        updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.constructor.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
        
        bitmap.executeAction updatePropertyAction
      ,
        1000
      
  class @FinalLine extends @LineOfType
    @type: -> StraightLine.SegmentLengths.Even
