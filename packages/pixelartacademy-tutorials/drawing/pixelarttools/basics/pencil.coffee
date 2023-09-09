LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.Pencil extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Pencil'

  @displayName: -> "Pencil"

  @description: -> """
      Learn how to use the most essential pixel art tool: a 1-pixel pencil.
    """

  @fixedDimensions: -> width: 8, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @goalBitmapString: -> """
      |   00
      |  0000
      | 000000
      |00 00 00
      |00000000
      | 0 00 0
      |0      0
      | 0    0
    """

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"
  
  @initialize()
  
  constructor: ->
    super arguments...
    
    @unlockEraser = new ReactiveField false

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser if @unlockEraser()
  ]
  
  Asset = @
  
  class @Tool extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tool"
    @assetClass: -> Asset
    
    @message: -> """
      Click on the pencil to activate it.
    """
    
    @activeConditions: ->
      return unless @getActiveAsset()
      
      # Show when pencil is not the active tool.
      editor = @getEditor()
      editor.interface.activeToolId() isnt LOI.Assets.SpriteEditor.Tools.Pencil.id()
    
    @initialize()
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
  
    @message: -> """
      Use the pencil to fill the pixels with the dot in the middle.
    """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
  
      # Show when pencil is the active tool.
      editor = @getEditor()
      return unless editor.interface.activeToolId() is LOI.Assets.SpriteEditor.Tools.Pencil.id()
    
      # Show until the asset is completed.
      not asset.completed()
      
    @initialize()
    
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      Whoops, you went too far! Use the eraser on the left to delete unwanted pixels.
    """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any extra pixels present.
      @assetHasExtraPixels asset

    @priority: -> 1
    
    @initialize()
  
    onDisplay: ->
      # Unlock the eraser.
      asset = @constructor.getActiveAsset()
      asset.unlockEraser true
      
  class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
        Great! Go back to your portfolio to find a new sprite to draw.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
