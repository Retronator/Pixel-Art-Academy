LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.ColorFill2 extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.ColorFill2'

  @displayName: -> "Color fill 2"

  @description: -> """
      Sometimes it's faster to fill too many pixels and then erase the extras.
    """

  @fixedDimensions: -> width: 12, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black

  @bitmapString: -> """
      |    0000
      | 000    000
      |0          0
      |0          0
      |000      000
      |   00  00
      |  00 00 00
      |00        00
    """

  @goalBitmapString: -> """
      |    0000
      | 0000000000
      |000000000000
      |000  00  000
      |000000000000
      |   00  00
      |  00 00 00
      |00        00
    """

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Eraser
  ]

  @initialize()
  
  Asset = @
  
  class @Instruction extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Instruction"
    @assetClass: -> Asset
    
    @message: -> """
      Use the color fill and eraser to complete the invader.
    """
    
    @initialize()
