LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Basics.Eraser extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Basics.Eraser'

  @displayName: -> "Eraser"

  @description: -> """
      Using the eraser, remove the pixels with the dot in the middle.
      If you delete too much, simply use the pencil to draw things back in.
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
