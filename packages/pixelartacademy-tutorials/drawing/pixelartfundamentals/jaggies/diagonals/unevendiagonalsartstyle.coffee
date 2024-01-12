AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
Markup = PAA.Practice.Helpers.Drawing.Markup
PAG = PAA.Practice.PixelArtEvaluation

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.UnevenDiagonalsArtStyle extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.UnevenDiagonalsArtStyle"

  @displayName: -> "Uneven diagonals as an art style"
  
  @description: -> """
    It's important to know that following any rules in art is always a choice.
  """
  
  @bitmapInfo: -> """
    Artwork from [Into The Breach](https://subsetgames.com/itb.html), 2018

    Artist: Jay Ma
  """
  
  @fixedDimensions: -> width: 56, height: 86
  @minClipboardScale: -> 1
  
  @resources: ->
    resources = layers: []
    
    for layer in [1..4]
      resources.layers.push new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/unevendiagonalsartstyle-#{layer}.png"
      
    resources

  @pixelArtEvaluation: -> true
  @markup: -> true
  
  @properties: ->
    pixelArtScaling: true
    pixelArtEvaluation:
      editable: true
      allowedCriteria: [PAG.Criteria.EvenDiagonals]
      evenDiagonals:
        segmentLengths: {}
  
  @initialize()
  
  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
  ]
  
  initializeSteps: ->
    fixedDimensions = @constructor.fixedDimensions()
    
    stepAreaBounds =
      x: 0
      y: 0
      width: fixedDimensions.width
      height: fixedDimensions.height
    
    stepArea = new @constructor.StepArea @, stepAreaBounds
    
    new @constructor.DisableEvenDiagonalsEvaluation @, stepArea,
      startPixels: @resources.layers
  
  Asset = @
  
  class @DisableEvenDiagonalsEvaluation extends TutorialBitmap.Step
    completed: ->
      not @tutorialBitmap.bitmap().properties.pixelArtEvaluation.evenDiagonals
      
    solve: ->
      # Disable pixel art evaluation.
      bitmap = @tutorialBitmap.bitmap()
      pixelArtEvaluation = bitmap.properties.pixelArtEvaluation
      delete pixelArtEvaluation.evenDiagonals
      
      updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @tutorialBitmap.id(), bitmap, 'pixelArtEvaluation', pixelArtEvaluation
      AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, updatePropertyAction, new Date
    
    hasPixel: (x, y) ->
      # We simply require pixels everywhere we have them.
      @tutorialBitmap.bitmap().findPixelAtAbsoluteCoordinates x, y
  
  class @Convention extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Convention"
    @assetClass: -> Asset
    
    @message: -> """
      Even diagonals are a convention and you can make great art with or without them, as you can see in this artwork from Into the Breach.
      The high viewing angle helps with the readability of the game board and creates a unique, standout style.
      
      Open the evaluation paper to continue.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      not asset.completed()
    
    @completedConditions: ->
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active()
    
    @resetCompletedConditions: ->
      return true unless @getActiveAsset()
      
      editor = @getEditor()
      pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      not pixelArtEvaluation.active()
      
    @priority: -> 1
    
    @initialize()
    
  class @TurnOff extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.TurnOff"
    @assetClass: -> Asset
    
    @message: -> """
      The use of uneven, broken diagonals here is a deliberate choice.
      You can choose too, so to complete this lesson, turn off Even diagonals evaluation by removing the required checkmark.
    """
    
    @displaySide: -> PAA.PixelPad.Systems.Instructions.DisplaySide.Top
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
      
      # Note: We have to activate only when the evaluation paper is open, so that the onActivate animation
      # happens immediately, even before the previous instruction hides and displays this one.
      return unless editor = @getEditor()
      return unless pixelArtEvaluation = editor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluation.active()
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      drawingEditor = @getEditor()
      pixelCanvas = drawingEditor.interface.getEditorForActiveFile()
      pixelCanvas.triggerSmoothMovement()
      
      camera = pixelCanvas.camera()
      
      originDataField = camera.originData()
      originDataField.value x: 28, y: 16

      scaleDataField = camera.scaleData()
      scaleDataField.value 5

    markup: ->
      return [] unless asset = @getActiveAsset()
      return [] unless pixelArtEvaluation = asset.pixelArtEvaluation()
      
      linePart = pixelArtEvaluation.getLinePartsAt(40, 21)[0]
      Markup.PixelArt.straightLineBreakdown linePart
