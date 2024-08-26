LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
LineArtCleanup = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LineArtCleanup

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
        allowedCriteria: [PAE.Criteria.SmoothCurves]
        smoothCurves:
          ignoreMostlyStraightLines: false
          abruptSegmentLengthChanges: {}
          straightParts: {}
          inflectionPoints: {}
      
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.constructor.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
      
      bitmap.executeAction updatePropertyAction
    
    completed: ->
      return true if super arguments...
      
      # Pixel art evaluation paper needs to be open.
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluationView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluationView.active()
  
  class @OpenSmoothCurves extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.activeCriterion() is PAE.Criteria.SmoothCurves

  class @AnalyzeTheCurve extends TutorialBitmap.EphemeralStep
    @timeToHover = 1
    @requiredAnalysisPerformed = 2
    
    constructor: ->
      super arguments...
      
      @timeHovered = 0
      @analysesPerformed = []
      
    completed: ->
      return true if super arguments...
      
      return @stopCountingTime() unless drawingEditor = @getEditor()
      return @stopCountingTime() unless pixelArtEvaluationView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      return @stopCountingTime() unless @currentAnalysisType = pixelArtEvaluationView.hoveredFilterValue()
      
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
          @analysesPerformed.push @currentAnalysisType unless @currentAnalysisType in @analysesPerformed
          
          @solve() if @analysesPerformed.length >= @constructor.requiredAnalysisPerformed
          
        else
          @countTime()
      ,
        100

  class @SmoothenTheCurve extends TutorialBitmap.PixelsStep
    completed: ->
      return unless super arguments...
      
      # There needs to be a line that goes through all goal pixels.
      return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()
      return unless line = pixelArtEvaluation.getLinesBetween(@goalPixels...)[0]
      
      # All smooth curves criteria need to be at 0.9 or more (A level).
      bitmap = @tutorialBitmap.bitmap()
      lineEvaluation = line.evaluate bitmap.properties.pixelArtEvaluation
      for categoryName, categoryEvaluation of lineEvaluation.curveSmoothness
        return unless categoryEvaluation.score >= 0.9
        
      true
