LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
AbruptSegmentLengthChanges = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.AbruptSegmentLengthChanges

class AbruptSegmentLengthChanges.Steps
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
        allowedCriteria: [PAE.Criteria.SmoothCurves]
        smoothCurves:
          abruptSegmentLengthChanges: {}
      
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.constructor.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
      
      bitmap.executeAction updatePropertyAction
  
  class @HoverOverTheCurve extends TutorialBitmap.EphemeralStep
    @timeToHover = 1.2
    
    constructor: ->
      super arguments...
      
      @timeHovered = 0
      
    completed: ->
      # Note: we can't rely on the parent implementation since it will fail due to there being extra pixels.
      return true if @_solved()
      
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
