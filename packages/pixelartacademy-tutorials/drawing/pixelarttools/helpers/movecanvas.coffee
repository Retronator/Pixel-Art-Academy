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
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

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

  minClipboardScale: -> 1
  
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
      
    @completedConditions: ->
      editor = @getEditor()
      editor.interface.activeToolId() is PAA.PixelPad.Apps.Drawing.Editor.Desktop.Tools.MoveCanvas.id()
      
    @resetCompletedCondition: ->
      not @getActiveAsset()
    
    @initialize()
  
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
  
    @resetCompletedCondition: ->
      not @getActiveAsset()
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      drawingEditor = @getEditor()
      pixelCanvasEditor = drawingEditor.interface.getEditorForActiveFile()
      @_initialOrigin = pixelCanvasEditor.camera().origin()
    
    completedConditions: ->
      drawingEditor = @getEditor()
      pixelCanvasEditor = drawingEditor.interface.getEditorForActiveFile()
      not EJSON.equals @_initialOrigin, pixelCanvasEditor.camera().origin()
