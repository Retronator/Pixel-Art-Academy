LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Colors.ColorPicking extends PAA.Tutorials.Drawing.PixelArtTools.Colors.ColorPickingWithUndo
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Colors.ColorPicking'

  @displayName: -> "Color picking"

  @description: -> """
      To switch between colors faster, pick them directly from the canvas.

      Shortcut: I (eyedropper)
    """

  @fixedDimensions: -> width: 12, height: 12
  @restrictedPaletteName: -> PAA.Tutorials.Drawing.PixelArtTools.Colors.pacManPaletteName
  @backgroundColor: -> LOI.Assets.Palette.defaultPalette()?.color LOI.Assets.Palette.Atari2600.hues.gray, 2

  @bitmapString: -> """
      |
      |
      |
      |
      | 1112
      |111211
      |11111
      |1c11
      |11c1
      | 111
      |
      |
    """

  @goalBitmapString: -> """
      |          22
      |        2222
      |      22 2
      |     2   2
      | 1112   2
      |111211 2
      |11111 1211
      |1c11 112111
      |11c1 111111
      | 111 1c1111
      |     11c111
      |      1111
    """

  @bitmapInfo: -> "Artwork from PAC-MAN, Namco, 1980"

  availableToolKeys: ->
    Helpers = PAA.Tutorials.Drawing.PixelArtTools.Helpers
    
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      PAA.Practice.Software.Tools.ToolKeys.Zoom if Helpers.isAssetCompleted Helpers.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas if Helpers.isAssetCompleted Helpers.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo if @unlockUndo() or Helpers.isAssetCompleted Helpers.UndoRedo
      PAA.Practice.Software.Tools.ToolKeys.Redo if Helpers.isAssetCompleted Helpers.UndoRedo
    ]

  @initialize()
  
  Asset = @
  
  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
        Click on the eyedropper to activate the color picker tool.

        Shortcut: I (eyedropper)
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      not asset.completed()
    
    @completedConditions: ->
      # Color picker has to be the active tool.
      editor = @getEditor()
      editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.ColorPicker.id()
  
    @resetCompletedConditions: ->
      not @getActiveAsset()
    
    @delayDuration: -> @defaultDelayDuration
    
    @initialize()
    
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Click somewhere on the drawing to pick that color.
    """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
      return if asset.completed()
  
      # Show when color picker is the active tool.
      editor = @getEditor()
      editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.ColorPicker.id()
  
    @resetCompletedConditions: ->
      not @getActiveAsset()
  
    @delayDuration: -> @defaultDelayDuration
    
    @initialize()
  
    onActivate: ->
      super arguments...
    
      editor = @getEditor()
      paintHelper = editor.interface.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.Paint
    
      @_initialColorRamp = paintHelper.paletteColor().ramp
  
    completedConditions: ->
      editor = @getEditor()
      paintHelper = editor.interface.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.Paint
    
      @_initialColorRamp isnt paintHelper.paletteColor().ramp
  
  class @Error extends PAA.Tutorials.Drawing.PixelArtTools.Colors.ColorPickingWithUndo.Error
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @initialize()
