LOI = LandsOfIllusions
PAA = PixelArtAcademy

TextOriginPosition = PAA.Practice.Helpers.Drawing.Markup.TextOriginPosition
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtTools.Helpers.Lines extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers.Lines'

  @displayName: -> "Lines"

  @description: -> """
      Learn how to quickly draw lines with the pencil tool.
    """

  @fixedDimensions: -> width: 57, height: 32
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black
  
  @steps: -> for step in [1..5]
    goalImageUrl: "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/720-#{step}.png"
    imageUrl: "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/720.png" if step is 1
  
  @bitmapInfo: -> "Artwork from 720° (ZX Spectrum), Atari, 1987"

  @markup: -> true

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
  ]
  
  initializeSteps: ->
    super arguments...
    
    # Allow steps to complete with extra pixels so that we can show only line ends, but continue with a line drawn.
    stepArea = @stepAreas()[0]
    
    for step, stepIndex in stepArea.steps() when stepIndex in [1, 2]
      step.options.canCompleteWithExtraPixels = true
      
  Asset = @
  
  class @InstructionStep extends PAA.Tutorials.Drawing.Instructions.Instruction
    @stepNumber: -> throw new AE.NotImplementedException "Instruction step must provide the step number."
    @assetClass: -> Asset
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show with the correct step.
      asset.stepAreas()[0].activeStepIndex() is @stepNumber() - 1

  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
      Select the pencil to start drawing as usual.
    """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
      not asset.completed()
      
    @completedConditions: ->
      editor = @getEditor()
      editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.Pencil.id()
    
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @initialize()
  
  class @LineStart extends @InstructionStep
    @id: -> "#{Asset.id()}.LineStart"
    @stepNumber: -> 1
    
    @message: -> """
      Click on the indicated pixel to start a new line.
    """
    
    @initialize()
    
    markup: ->
      markupStyle = Markup.defaultStyle()
      
      arrowBase =
        arrow:
          end: true
        style: markupStyle
      
      textBase = Markup.textBase()
      
      [
        line: _.extend {}, arrowBase,
          points: [
            x: 4, y: 20.5
          ,
            x: 5.5, y: 23.5, bezierControlPoints: [
              x: 4, y: 22
            ,
              x: 5.25, y: 23.25
            ]
          ]
        text: _.extend {}, textBase,
          position:
            x: 4, y: 20, origin: TextOriginPosition.BottomCenter
          value: "start\nhere"
      ]
  
  class @LineEnd extends @InstructionStep
    @id: -> "#{Asset.id()}.LineEnd"
    @stepNumber: -> 2
    
    @message: -> """
      Hold the shift key and click on the end pixel to place down the line.
    """
    
    @initialize()
  
  class @LineSequence extends @InstructionStep
    @id: -> "#{Asset.id()}.LineSequence"
    @stepNumber: -> 3
    
    @message: -> """
      You can keep holding the shift key to connect multiple lines in a row.
    """

    @initialize()
    
  class @SeparateLines extends @InstructionStep
    @id: -> "#{Asset.id()}.SeparateLines"
    @stepNumber: -> 4
    
    @message: -> """
      Release shift whenever you want to start a separate line.
    """

    @initialize()
