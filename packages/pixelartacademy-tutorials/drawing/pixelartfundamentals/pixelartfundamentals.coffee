AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class PAA.Tutorials.Drawing.PixelArtFundamentals
  @enablePixelArtEvaluation: (criterion, enableCriterion) ->

  # The length of the arrow to indicate a pixel move.
  @movePixelArrowLength = 1.2
  
  class @OpenEvaluationPaper extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      # Pixel art evaluation paper needs to be open.
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluationView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluationView.active()
      
  class @OpenEvaluationCriterion extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.activeCriterion() is @options.criterion
      
  class @CloseEvaluationPaper extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      active = pixelArtEvaluation.active()
      
      return true if @_wasActive and not active
      
      @_wasActive = active
      
      false
