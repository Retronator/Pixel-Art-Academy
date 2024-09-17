LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
StraightParts = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.StraightParts

class StraightParts.Steps
  class @DrawAndAnalyze extends TutorialBitmap.PixelsWithPathsStep
    completed: ->
      return unless super arguments...
      
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.activeCriterion() is PAE.Criteria.SmoothCurves
      
  class @CloseEvaluationPaper extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      # Pixel art evaluation paper must not be open.
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluationView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      not pixelArtEvaluationView.active()
