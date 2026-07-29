LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
LineArtCleanup = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LineArtCleanup
Atari2600 = LOI.Assets.Palette.Atari2600

_topLeftCorner = new THREE.Vector2
_bottomRightCorner = new THREE.Vector2
_symbolHintTextOffset = 0.5 + 0.5 / 12

class LineArtCleanup.Steps
  class @RequiredPixelsStep extends TutorialBitmap.PixelsStep
    drawOverlaidHints: (context, renderOptions = {}) ->
      @_prepareColorHelp context, renderOptions
  
      palette = LOI.palette()
      glowColor = palette.color Atari2600.hues.gray, 7
      pixelColor = palette.color Atari2600.hues.gray, 0
    
      for pixel in @goalPixels
        absoluteX = pixel.x + @stepArea.bounds.x
        absoluteY = pixel.y + @stepArea.bounds.y
        
        _topLeftCorner.x = absoluteX
        _topLeftCorner.y = absoluteY
        renderOptions.camera.roundCanvasToWindowPixel _topLeftCorner, _topLeftCorner
        
        _bottomRightCorner.x = absoluteX + 1
        _bottomRightCorner.y = absoluteY + 1
        renderOptions.camera.roundCanvasToWindowPixel _bottomRightCorner, _bottomRightCorner
  
        # Draw a radial gradient from the center of the pixel.
        hintGlowErrorGradient = context.createRadialGradient absoluteX + 0.5, absoluteY + 0.5, 0, absoluteX + 0.5, absoluteY + 0.5, 0.5
        hintGlowErrorGradient.addColorStop 0, "rgba(#{glowColor.r * 255}, #{glowColor.g * 255}, #{glowColor.b * 255}, 0.5)"
        hintGlowErrorGradient.addColorStop 1, "rgba(#{glowColor.r * 255}, #{glowColor.g * 255}, #{glowColor.b * 255}, 0)"
        context.fillStyle = hintGlowErrorGradient
        context.fillRect absoluteX, absoluteY, 1, 1

        context.fillStyle = "rgba(#{pixelColor.r * 255}, #{pixelColor.g * 255}, #{pixelColor.b * 255}, #{@_hintOpacity})"
    
        if @_hintStyle is @_ColorHelp.HintStyle.Dots
          context.fillRect _topLeftCorner.x + @_dotHintOffset, _topLeftCorner.y + @_dotHintOffset, @_dotHintSize, @_dotHintSize
          
        else
          # Draw the symbol hint.
          serialIndex = LOI.Assets.ColorHelper.getSerialIndexForAssetColor palette, pixel
          symbol = PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.symbols[serialIndex]
    
          # Write the symbol in the center of the pixel.
          context.fillText symbol, absoluteX + _symbolHintTextOffset, absoluteY + _symbolHintTextOffset

      # Explicit return to avoid result collection.
      return
    
  class @DrawLine extends @RequiredPixelsStep
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
      return unless pixelArtEvaluation.getLinesBetween(@goalPixels...)[0]
      
      # The lines must not have any doubles or corners.
      for line in pixelArtEvaluation.layers[0].lines
        lineEvaluation = line.evaluate LineArtCleanup._pixelPerfectLinesEvaluationProperty
        return if lineEvaluation.doubles.count or lineEvaluation.corners.count
        
      true
  
  class @OpenEvaluationPaper extends PAA.Tutorials.Drawing.PixelArtFundamentals.OpenEvaluationPaper
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

  class @SmoothenTheCurve extends @RequiredPixelsStep
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
