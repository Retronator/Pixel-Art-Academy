LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Basics.Pencil extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Basics.Pencil'

  @displayName: -> "Pencil"

  @description: -> """
      Using the pencil, fill the pixels with the dot in the middle.
      Click start when you're ready. If you make a mistake, come back and reset the challenge.
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

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
  ]

  @initialize()
