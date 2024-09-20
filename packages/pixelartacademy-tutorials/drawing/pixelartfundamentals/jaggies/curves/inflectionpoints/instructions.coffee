LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions
InflectionPoints = PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.InflectionPoints
TextOriginPosition = PAA.Practice.Helpers.Drawing.Markup.TextOriginPosition
Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking

class InflectionPoints.Instructions
  class @StepInstruction extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @assetClass: -> InflectionPoints
    
    # The amount of time before we show instructions to the user after a new UI element is introduced.
    @uiRevealDelayDuration = 3
    
    @getPixelArtEvaluation: ->
      drawingEditor = @getEditor()
      drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
  
    translateAndScaleTo: (x, y, scale) ->
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      
      camera.translateTo {x, y}, 1
      camera.scaleTo scale, 1
      
    movePixelMarkup: (x, y, dx, dy) ->
      return [] unless asset = @getActiveAsset()
      bitmap = asset.bitmap()
      
      return [] if bitmap.findPixelAtAbsoluteCoordinates x + dx, y + dy
      
      movePixelArrowLength = PAA.Tutorials.Drawing.PixelArtFundamentals.movePixelArrowLength
      
      [
        line:
          arrow:
            end: true
            width: 0.5
            length: 0.25
          style: Markup.errorStyle()
          points: [
            x: x + 0.5, y: y + 0.5
          ,
            x: x + 0.5 + movePixelArrowLength * dx, y: y + 0.5 + movePixelArrowLength * dy
          ]
      ]
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom

  class @RemoveDoubles extends @StepInstruction
    @id: -> "#{InflectionPoints.id()}.RemoveDoubles"
    @stepNumber: -> 1
    
    @message: -> """
      When we draw curves freehand, the general placement is correct, but the line can end up wobbly.

      Remove the doubles as indicated.
    """
    
    @initialize()
  
  class @OpenSmoothCurves extends @StepInstruction
    @id: -> "#{InflectionPoints.id()}.OpenSmoothCurves"
    @stepNumbers: -> [2, 3]
    
    @message: -> """
      Open the Smooth curves breakdown to analyze inflection points.
    """
    
    @priority: -> 1
    
    @activeConditions: ->
      return unless super arguments...
      
      # Show if the pixel art evaluation paper is not on the smooth curves criterion.
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      return true unless pixelArtEvaluation.active()
      pixelArtEvaluation.activeCriterion() isnt PAE.Criteria.SmoothCurves
    
    @initialize()

  class @HoverInflectionPointsScore extends @StepInstruction
    @id: -> "#{InflectionPoints.id()}.HoverInflectionPointsScore"
    @stepNumber: -> 3
    
    @message: -> """
      Hover over the inflection points score to see how the curve changes direction.
    """
    
    @delayDuration: -> @uiRevealDelayDuration
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      @translateAndScaleTo 21, 14, 4
      
    markup: ->
      markup = []
      
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      markup.push
        interface:
          selector: '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelartevaluation'
          delay: 1
          bounds:
            x: 170
            y: 0
            width: 80
            height: 120
          markings: [
            rectangle:
              strokeStyle: markupStyle
              x: 181.5
              y: 29
              width: 20
              height: 8.5
            line: _.extend {}, arrowBase,
              points: [
                x: 235, y: 19
              ,
                x: 205, y: 36, bezierControlPoints: [
                  x: 235, y: 31
                ,
                  x: 215, y: 36
                ]
              ]
            text: _.extend {}, textBase,
              position:
                x: 235, y: 17, origin: Markup.TextOriginPosition.BottomCenter
              value: "hover\nhere"
          ]
      
      markup
      
  class @InflectionPointsExplanation extends @StepInstruction
    @id: -> "#{InflectionPoints.id()}.InflectionPointsExplanation"
    @stepNumber: -> 4
    
    @message: -> """
      Wobbly lines keep changing direction so they end up with many inflection points close together.
      
      Close the evaluation paper and improve the curve to only have a couple of isolated inflection points.
    """
    
    @initialize()

  class @InflectionPointsMarkup extends @StepInstruction
    markup: ->
      return unless asset = @getActiveAsset()
      return unless pixelArtEvaluation = asset.pixelArtEvaluation()
    
      markup = []
      markup.push @movePixelMarkup(13, 5, 0, -1)...
      markup.push @movePixelMarkup(13, 14, 0, 1)...
      markup.push @movePixelMarkup(15, 24, 0, 1)...
      markup.push @movePixelMarkup(32, 22, 0, -1)...
      
      betterStyle = Markup.betterStyle()
      mediocreStyle = Markup.mediocreStyle()
      worseStyle = Markup.worseStyle()
      
      for line in pixelArtEvaluation.layers[0].lines
        {curveSmoothness} = line.evaluate()
        
        # Ignore lines without curves.
        continue unless curveSmoothness
        
        for inflectionPoint in curveSmoothness.inflectionPoints.points
          style = switch
            when inflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.dense then worseStyle
            when inflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.sparse then mediocreStyle
            else betterStyle
          
          point =
            x: inflectionPoint.position.x + 0.5
            y: inflectionPoint.position.y + 0.5
            style: style
            radius: 2
            
          markup.push {point}
        
        for curve in line.curvatureCurveParts
          perceivedLineMarkup = Markup.PixelArt.perceivedCurve curve
          perceivedLineMarkup.line.arrow = end: true
          perceivedLineMarkup.line.style = betterStyle
          
          if curveSmoothness.inflectionPoints.points.length
            # Color the line according to the spacing score of the closest inflection point.
            closestInflectionPoint = _.minBy curveSmoothness.inflectionPoints.points, (point) =>
              # Constraint to points inside the curve bounds.
              if curve.startSegmentIndex <= point.inflectionArea.averageEdgeSegmentIndex <= curve.endSegmentIndex
                distanceToStartSegment = point.inflectionArea.averageEdgeSegmentIndex - curve.startSegmentIndex
                distanceToEndSegment = curve.endSegmentIndex - point.inflectionArea.averageEdgeSegmentIndex
                Math.min distanceToStartSegment, distanceToEndSegment
                
              else
                Number.POSITIVE_INFINITY
              
            perceivedLineMarkup.line.style = switch
              when closestInflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.dense then worseStyle
              when closestInflectionPoint.spacingScore < PAE.Line.Part.Curve.inflectionPointSpacingThresholds.sparse then mediocreStyle
              else betterStyle
          
          perceivedLineMarkup.line.points = Markup.offsetPoints perceivedLineMarkup.line.points, if curve.clockwise then -2.5 else 2.5
          
          markup.push perceivedLineMarkup
      
      markup
    
  class @FixLine extends @InflectionPointsMarkup
    @id: -> "#{InflectionPoints.id()}.FixLine"
    @stepNumber: -> 5
    
    @activeDisplayState: ->
      # We only have markup without a message.
      InstructionsSystem.DisplayState.Hidden
    
    @initialize()
    
  class @Complete extends @InflectionPointsMarkup
    @id: -> "#{InflectionPoints.id()}.Complete"
    
    @message: -> """
      Well done! As always, isolation points are not a problem where the change of direction is intended,
      even if there are many close by (for example, drawing ocean waves).
    """
  
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
      
    @initialize()
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
