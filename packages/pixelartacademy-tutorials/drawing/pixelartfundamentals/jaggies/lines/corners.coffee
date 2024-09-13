AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
Markup = PAA.Practice.Helpers.Drawing.Markup
InterfaceMarking = PAA.PixelPad.Systems.Instructions.InterfaceMarking
InstructionsSystem = PAA.PixelPad.Systems.Instructions

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Corners extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Corners"

  @displayName: -> "Corners"
  
  @description: -> """
    Sharp edges can be used intentionally.
  """

  @fixedDimensions: -> width: 55, height: 28
  
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 0, g: 0, b: 0]
      ,
        shades: [r: 1, g: 0.8, b: 0.2]
      ]
  
  @resources: ->
    imagePixelsOptions = palette: => @customPalette()
    
    steps: for step in [1..2]
      startPixels: new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/corners-#{step}.png", imagePixelsOptions
      goalPixels: new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/corners-#{step}-goal.png", imagePixelsOptions

  @pixelArtEvaluation: -> true
  
  @properties: ->
    pixelArtScaling: true
    pixelArtEvaluation:
      editable: true
      allowedCriteria: [PAE.Criteria.PixelPerfectLines]
      pixelPerfectLines:
        doubles: {}
        corners:
          ignoreStraightLineCorners: false
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    stepArea = @stepAreas()[0]
    steps = stepArea.steps()
    
    # The first step should not show goal pixels.
    steps[0].options.drawHintsForGoalPixels = false

    # Add step for disabling the corners criterion.
    new @constructor.DisableCornersEvaluation @, stepArea
  
  Asset = @
  
  class @DisableCornersEvaluation extends TutorialBitmap.Step
    completed: ->
      not @tutorialBitmap.bitmap().properties.pixelArtEvaluation.pixelPerfectLines?.corners
      
    solve: ->
      # Disable pixel art evaluation.
      bitmap = @tutorialBitmap.bitmap()
      pixelArtEvaluation = bitmap.properties.pixelArtEvaluation
      delete pixelArtEvaluation.pixelPerfectLines.corners
      
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
      AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, updatePropertyAction, new Date
    
  class @Outline1 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Outline1"
    @assetClass: -> Asset
    @stepNumber: -> 1
    
    @message: -> """
      Add a black outline to the outside of the star by following the rules discussed so far (use rows and columns of pixels that touch only in corners).
    """

    @initialize()
  
  class @Outline2 extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.Outline2"
    @assetClass: -> Asset
    @stepNumber: -> 2
    
    @message: -> """
      Using these rules leads to rounded corners, which is great if you're after a softer look. However, if sharp corners are desired, using a more spiky line art is OK.
    """
    
    @initialize()
  
  class @OpenEvaluation extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.OpenEvaluation"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      Open the pixel art evaluation paper and look at the corners analysis.
    """
    
    @completedConditions: ->
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active()
    
    @resetCompletedConditions: ->
      return true unless @getActiveAsset()
      
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      not pixelArtEvaluation.active()
    
    @priority: -> 2
    
    @initialize()
    
  class @SelectCriterion extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.SelectCriterion"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      The definition of pixel-perfect lines doesn't allow for corners, so they are highlighted as an error.
      However, the evaluation doesn't understand the context.
      
      Open the Pixel-perfect lines breakdown to continue.
    """
    
    @completedConditions: ->
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active() and pixelArtEvaluation.activeCriterion() is PAE.Criteria.PixelPerfectLines
    
    @resetCompletedConditions: ->
      return true unless @getActiveAsset()
      
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      not pixelArtEvaluation.active() or pixelArtEvaluation.activeCriterion() isnt PAE.Criteria.PixelPerfectLines
    
    @priority: -> 1
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top

    @initialize()
    
    onDisplayed: ->
      super arguments...
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      
      camera = pixelCanvas.camera()
      
      camera.translateTo {x: 27, y: 12}, 1
      camera.scaleTo 4, 1
    
    markup: -> PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.pixelArtEvaluationClickHereCriterionMarkup '.pixel-perfect-lines'
  
  class @TurnOff extends PAA.Tutorials.Drawing.Instructions.StepInstruction
    @id: -> "#{Asset.id()}.TurnOff"
    @assetClass: -> Asset
    @stepNumber: -> 3
    
    @message: -> """
      The evaluation paper can only show potential problems. Don't worry about the corners that are intentional.
      You can even turn individual criteria off completely.
      
      Do that now by removing the checkmark next to the Corners criterion.
    """
    
    @displaySide: -> PAA.PixelPad.Systems.Instructions.DisplaySide.Top
    
    @initialize()
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".pixelartacademy-pixelpad-apps-drawing-editor-desktop-pixelartevaluation .corners .checkmark-area"
          delay: 1
          bounds:
            x: -50
            y: -35
            width: 70
            height: 55
          markings: [
            rectangle:
              strokeStyle: markupStyle
              x: 2
              y: 1.5
              width: 13
              height: 11.5
            line: _.extend {}, arrowBase,
              points: [
                x: -32, y: -9
              ,
                x: -2, y: 7, bezierControlPoints: [
                  x: -32, y: 3
                ,
                  x: -15, y: 7
                ]
              ]
            text: _.extend {}, textBase,
              position:
                x: -32, y: -11, origin: Markup.TextOriginPosition.BottomCenter
              value: "click here"
          ]
      ]
    
  class @Complete extends PAA.Tutorials.Drawing.Instructions.CompleteInstruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
      Great! Only use the evaluation as a tool to double-check your work and do not follow it blindly.
      It makes mistakes and doesn't know your intentions so take its scores with a big grain of salt.
    """

    @initialize()
    
    displaySide: ->
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluation = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      
      if pixelArtEvaluation.active() then InstructionsSystem.DisplaySide.Top else InstructionsSystem.DisplaySide.Bottom
