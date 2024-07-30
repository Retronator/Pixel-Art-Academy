LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Helpers.MoveCanvas extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers.MoveCanvas'

  @displayName: -> "Move image"

  @description: -> """
      When working on a bigger artwork, you'll need to move it around to focus on different details.

      Shortcut: H (hand)

      Quick shortcut: space
    """

  @fixedDimensions: -> width: 256, height: 32
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black
  @minClipboardScale: -> 1

  @imageUrl: ->
    "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/outrun-hills.png"

  @goalImageUrl: ->
    "/pixelartacademy/tutorials/drawing/pixelarttools/helpers/outrun-hills-goal.png"

  @bitmapInfo: -> "Artwork from Out Run (ZX Spectrum), Probe Software, 1987"

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
  ]
  
  Asset = @
  
  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
        Hold down the space bar to temporarily switch to the hand cursor.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      not asset.completed()
      
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @initialize()
  
    completedConditions: ->
      # Don't show this instruction after the move was made.
      @instructions.getInstruction(Asset.Instruction).completed()
      
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Click and drag to move the image around the table.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
  
      editor = @getEditor()
      editor.interface.activeToolId() is PAA.PixelPad.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas.id()
  
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @priority: -> 1
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      drawingEditor = @getEditor()
      pixelCanvasEditor = drawingEditor.interface.getEditorForActiveFile()
      @_initialOrigin = pixelCanvasEditor.camera().origin()
    
    completedConditions: ->
      # Wait until the origin has been changed.
      return unless drawingEditor = @getEditor()
      pixelCanvasEditor = drawingEditor.interface.getEditorForActiveFile()
      return if EJSON.equals @_initialOrigin, pixelCanvasEditor.camera().origin()
  
      # Wait until the move has finished so the text doesn't disappear immediately.
      moveCanvas = drawingEditor.interface.activeTool()
      not moveCanvas.moving()
