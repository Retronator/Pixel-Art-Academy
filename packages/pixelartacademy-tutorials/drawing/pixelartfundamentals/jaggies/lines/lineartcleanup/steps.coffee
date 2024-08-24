LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
LineArtCleanup = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.LineArtCleanup

class LineArtCleanup.Steps
  class @DrawLine extends TutorialBitmap.PathStep
    @preserveCompleted: -> true
    
    constructor: (tutorialBitmap, stepArea, options = {}) ->
      options.tolerance = 2
      super tutorialBitmap, stepArea, options
    
    completed: ->
      return unless super arguments...
      
      # Wait until the line has stopped drawing, otherwise adding pixel art
      # evaluation properties will happen in-between the stroke and get lost.
      return if @tutorialBitmap.bitmap().partialAction
      
      # There needs to be a line present.
      return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()
      pixelArtEvaluation.layers[0].lines.length
      
  class @OpenEvaluationPaper extends TutorialBitmap.EphemeralStep
    activate: ->
      super arguments...
      
      bitmap = @tutorialBitmap.bitmap()
      
      pixelArtEvaluation =
        allowedCriteria: [PAE.Criteria.PixelPerfectLines]
        pixelPerfectLines:
          doubles:
            countAllLineWidthTypes: true
            countPointsWithMultiplePixels: true
          corners:
            ignoreStraightLineCorners: false
      
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

  class @CleanLine extends @DrawLine
    completed: ->
      return unless super arguments...
      
      # The lines must not have any doubles or corners.
      return unless pixelArtEvaluation = @tutorialBitmap.pixelArtEvaluation()

      pixelArtEvaluationProperty = @tutorialBitmap.bitmap().properties.pixelArtEvaluation
      
      for line in pixelArtEvaluation.layers[0].lines
        lineEvaluation = line.evaluate pixelArtEvaluationProperty
        return if lineEvaluation.doubles.count or lineEvaluation.corners.count
        
      true
