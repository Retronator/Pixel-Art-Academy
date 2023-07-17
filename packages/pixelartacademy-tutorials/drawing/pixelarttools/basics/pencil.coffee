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
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
  
    @message: -> """
      Use the pencil to fill the pixels with the dot in the middle.
    """
    
    @initialize()
    
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      Whoops, you went too far! Use the eraser to delete unwanted pixels.
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
