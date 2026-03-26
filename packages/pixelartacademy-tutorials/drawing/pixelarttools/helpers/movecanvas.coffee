LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Helpers.MoveCanvas extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Helpers.MoveCanvas'

  @displayName: -> "Move image"

  @description: -> """
      When working on a bigger artwork, you'll need to move it around to focus on different details.

      Shortcut: H (hand)

      Quick shortcuts: space or middle mouse button
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
        Hold down the space bar or middle mouse button to temporarily switch to the hand cursor.
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

    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @priority: -> 1
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      drawingEditor = @getEditor()
      pixelCanvasEditor = drawingEditor.interface.getEditorForActiveFile()
      @_initialOrigin = pixelCanvasEditor.camera().origin()
    
    activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
      
      drawingEditor = @getEditor()
      
      # If the origin has been changed, the instruction needs to keep being active so it can
      # be completed even if the tool changes (like it does when activated via the hold button).
      if @_initialOrigin
        pixelCanvasEditor = drawingEditor.interface.getEditorForActiveFile()
        return true unless EJSON.equals @_initialOrigin, pixelCanvasEditor.camera().origin()
      
      drawingEditor.interface.activeToolId() is PAA.PixelPad.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas.id()
    
    completedConditions: ->
      # Wait until the origin has been changed.
      return unless drawingEditor = @getEditor()
      pixelCanvasEditor = drawingEditor.interface.getEditorForActiveFile()
      return if EJSON.equals @_initialOrigin, pixelCanvasEditor.camera().origin()
  
      # Wait until the move has finished so the text doesn't disappear immediately.
      if drawingEditor.interface.activeToolId() is PAA.PixelPad.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas.id()
        moveCanvas = drawingEditor.interface.activeTool()
        not moveCanvas.moving()
        
      else
        true
