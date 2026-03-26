LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
InflectionPoints = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.InflectionPoints

class InflectionPoints.Steps
  class @AnalyzeInflectionPoints extends TutorialBitmap.EphemeralStep
    @timeToHover = 1.2
    
    completed: ->
      # Note: we can't rely on the parent implementation since it will fail due to there being extra pixels.
      return true if @_solved()
      
      return @stopCountingTime() unless drawingEditor = @getEditor()
      return @stopCountingTime() unless pixelArtEvaluationView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      return @stopCountingTime() unless pixelArtEvaluationView.hoveredFilterValue() is PAE.Subcriteria.SmoothCurves.InflectionPoints
      
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
