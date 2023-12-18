LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
PAG = PAA.Practice.PixelArtGrading
StraightLine = PAG.Line.Part.StraightLine
DiagonalsGrading = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.DiagonalsGrading

class DiagonalsGrading.Steps
  class @OpenGradingSheet extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      drawingEditor = @getEditor()
      pixelArtGrading = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading
      pixelArtGrading.active()
    
  class @ClickOnEvenDiagonals extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      drawingEditor = @getEditor()
      pixelArtGrading = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading
      pixelArtGrading.activeCriterion() is PAG.Criteria.EvenDiagonals
    
  class @HoverOverTheDiagonal extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      drawingEditor = @getEditor()
      pixelArtGradingView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading
      return unless hoveredPixel = pixelArtGradingView.hoveredPixel()
      
      pixelArtGrading = pixelArtGradingView.pixelArtGrading()
      pixelArtGrading.getLinePartsAt(hoveredPixel.x, hoveredPixel.y).length
      
  class @LineGradingStep extends TutorialBitmap.PathStep
    @drawHintsAfterCompleted: -> false
  
    getLineGrading: ->
      return unless pixelArtGrading = @tutorialBitmap.pixelArtGrading()
      
      linePartsAtCorners = for cornersForPart in @paths[0].cornersOfParts
        for corner in cornersForPart
          pixelArtGrading.getLinePartsAt corner.x, corner.y
      
      linePartsAtCorners = _.flatten linePartsAtCorners
      linePartsAtAllCorners = _.intersection linePartsAtCorners...
      
      return unless linePart = linePartsAtAllCorners[0]
      return unless linePart instanceof StraightLine
      
      linePart.grade()
      
  class @LineOfType extends @LineGradingStep
    @type: -> throw new AE.NotImplementedException "A line of type step must provide the type needed for completion."
    
    completed: ->
      # Don't allow to continue if drawing outside of bounds.
      return if @stepArea.hasExtraPixels() and @isActiveStepInArea()

      # Ensure ideal results by also requiring matching ends.
      return unless lineGrading = @getLineGrading()
      return unless lineGrading.endSegments.type is StraightLine.EndSegments.Matching

      lineGrading.segmentLengths.type is @constructor.type()
  
  class @AlternatingLine extends @LineOfType
    @type: -> StraightLine.SegmentLengths.Alternating
  
  class @CloseGradingSheet extends TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      drawingEditor = @getEditor()
      pixelArtGrading = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtGrading
      active = pixelArtGrading.active()
      
      return true if @_wasActive and not active
      
      @_wasActive = active
      
      false
      
  class @EnableEndSegments extends @OpenGradingSheet
    activate: ->
      super arguments...
      
      # Execute action with a delay so that the current stroke action has time to complete and the pixel art grading
      # gets updated. Otherwise the pixel art grading property would get overwritten with old data. Additionally,
      # this makes it more obvious to the user that a new part of the grading sheet was unlocked.
      Meteor.setTimeout =>
        bitmap = @tutorialBitmap.bitmap()
        
        pixelArtGrading = EJSON.clone bitmap.properties.pixelArtGrading
        pixelArtGrading.evenDiagonals.endSegments = {}
        
        updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.constructor.id(), bitmap, 'pixelArtGrading', pixelArtGrading
        
        bitmap.executeAction updatePropertyAction
      ,
        1000
      
  class @FinalLine extends @LineOfType
    @type: -> StraightLine.SegmentLengths.Even
