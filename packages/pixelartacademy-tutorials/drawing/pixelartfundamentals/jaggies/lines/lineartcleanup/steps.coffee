LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
LineArtCleanup = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.LineArtCleanup

class LineArtCleanup.Steps
  class @DrawLine extends TutorialBitmap.PixelsStep
    @preserveCompleted: -> true

    hasPixel: ->
      # Allow drawing everywhere.
      true
      
    completed: ->
      return unless super arguments...
      
      # Wait until the current stroke action has completed.
      bitmap = @tutorialBitmap.bitmap()
      return if bitmap.partialAction
      
      # There needs to be a line that goes through all goal pixels.
      return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()
      pixelArtEvaluation.getLinesBetween(@goalPixels...)[0]
      
  class @OpenEvaluationPaper extends TutorialBitmap.EphemeralStep
    activate: ->
      super arguments...
      
      bitmap = @tutorialBitmap.bitmap()
      
      pixelArtEvaluation =
        allowedCriteria: [PAE.Criteria.PixelPerfectLines]
        pixelPerfectLines:
          doubles: {}
          corners: {}
      
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.constructor.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
      
      bitmap.executeAction updatePropertyAction
    
    completed: ->
      return true if super arguments...
      
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active()
  
  class @OpenPixelPerfectLines extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.activeCriterion() is PAE.Criteria.PixelPerfectLines
  
  class @HoverOverCriterion extends TutorialBitmap.EphemeralStep
    @timeToHover = 0.5
    
    completed: ->
      return true if super arguments...
      
      # We don't require this step if there are no doubles.
      return @stopCountingTime() unless bitmap = @tutorialBitmap.bitmap()
      return true unless bitmap.properties.pixelArtEvaluation.pixelPerfectLines.corners.count
      
      return @stopCountingTime() unless drawingEditor = @getEditor()
      return @stopCountingTime() unless pixelArtEvaluationView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      return @stopCountingTime() unless pixelArtEvaluationView.hoveredFilterValue()
      
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
      
  class @CloseEvaluationPaper extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      not pixelArtEvaluation.active()

  class @CleanLine extends TutorialBitmap.PixelsStep
    completed: ->
      return unless super arguments...
      
      # There needs to be a line that goes through all goal pixels.
      return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()
      return unless line = pixelArtEvaluation.getLinesBetween(@goalPixels...)[0]
      
      # The line must not have any doubles or corners.
      lineEvaluation = line.evaluate()
      not lineEvaluation.doubles.count and not lineEvaluation.corners.count
