LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Basics.ColorFill extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Basics.ColorFill'

  @displayName: -> "Color fill"

  @description: -> """
      Click on the glass to activate the color fill tool. Then click on the drawing to 'spill' your color
      automatically all the way to other colored pixel.
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

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
  ]

  @initialize()
