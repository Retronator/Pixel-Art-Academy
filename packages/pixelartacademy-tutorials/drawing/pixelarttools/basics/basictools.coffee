LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.BasicTools extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.BasicTools'

  @displayName: -> "Basic tools"

  @description: -> """
      Now that you know the 3 most essential tools, use them in unison to quickly complete the sprite.
    """

  @fixedDimensions: -> width: 16, height: 7
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @bitmapString: -> """
      |     000000
      |   00      00
      |  0          0
      | 0            0
      |0000000000000000
    """

  @goalBitmapString: -> """
      |     000000
      |   0000000000
      |  000000000000
      | 00 00 00 00 00
      |0000000000000000
      |  000  00  000
      |   0        0
    """

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
  ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
  
    @message: -> """
      Use the pencil, color fill, and eraser to demonstrate your use of all 3 basic drawing tools.
    """
    
    @initialize()
