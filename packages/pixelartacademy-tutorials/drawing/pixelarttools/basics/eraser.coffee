LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.Eraser extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Eraser'

  @displayName: -> "Eraser"

  @description: -> """
      As you can imagine, the eraser is great for removing extra pixels.
    """

  @fixedDimensions: -> width: 8, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmapString: -> """
      00000000
      00000000
      00000000
      00000000
      00000000
      00000000
      00000000
      00000000
    """

  @goalBitmapString: -> """
      |   00
      |  0000
      | 000000
      |00 00 00
      |00000000
      |  0  0
      | 0 00 0
      |0 0  0 0
    """

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
  ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Use the eraser to remove the pixels with the dot in the middle.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when asset has extra pixels so that we don't display it when there are missing pixels.
      @assetHasExtraPixels asset
    
    @initialize()

  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      You deleted a bit too much! Use the pencil to draw pixels back in.
    """

    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when there are any missing pixels present.
      @assetHasMissingPixels asset

    @priority: -> 1
    
    @initialize()
    
  class @Complete extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Complete"
    @assetClass: -> Asset
    
    @message: -> """
        Nice! Continue working through the rest of the sprites to complete the Basics tutorial.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
