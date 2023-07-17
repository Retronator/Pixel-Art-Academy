LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.ColorFill extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.ColorFill'

  @displayName: -> "Color fill"

  @description: -> """
      Learn how to fill in big areas of color quickly.
    """

  @fixedDimensions: -> width: 13, height: 9
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmapString: -> """
      |      0
      |     0 0
      |     0 0
      |     0 0
      | 00000 00000
      |0           0
      |0           0
      |0           0
      |0000000000000
    """

  @goalBitmapString: -> """
      |      0
      |     000
      |     000
      |     000
      | 00000000000
      |0000000000000
      |0000000000000
      |0000000000000
      |0000000000000
    """

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"
  
  constructor: ->
    super arguments...
  
    @unlockUndo = new ReactiveField false
    
  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Undo if @unlockUndo()
  ]

  @initialize()
  
  Asset = @
  
  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
        Click on the glass to activate the color fill tool.
      """
    
    @activeConditions: ->
      return unless @getActiveAsset()
      
      # Show when color fill is not the active tool.
      editor = @getEditor()
      editor.interface.activeToolId() isnt LOI.Assets.SpriteEditor.Tools.ColorFill.id()
    
    @delayDuration: -> @defaultDelayDuration
    
    @initialize()
    
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Click on the drawing to 'spill' your color all the way to differently colored pixels.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
  
      # Show when color fill is the active tool.
      editor = @getEditor()
      return unless editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.ColorFill.id()
  
      # Show until the asset is completed.
      super arguments...
    
    @initialize()
    
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      Whoops, you filled the area outside the lines! Use the undo button to get back on track.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any extra pixels present.
      @assetHasExtraPixels asset

    @priority: -> 1
    
    @initialize()
  
    onDisplay: ->
      # Unlock the undo.
      asset = @constructor.getActiveAsset()
      asset.unlockUndo true
