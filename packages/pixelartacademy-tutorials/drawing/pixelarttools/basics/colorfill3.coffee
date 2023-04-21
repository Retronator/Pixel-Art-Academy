LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.ColorFill3 extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.ColorFill3'

  @displayName: -> "Color fill 3"

  @description: -> """
      Use the pencil to fill the holes in the outline before using the color fill.
    """

  @fixedDimensions: -> width: 24, height: 18
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmapString: -> """
      |
      |     00000000000000
      |    0              0
      |   0                0
      |  0                  0
      | 0                    0
      | 0
      | 0                    0
      | 0                    0
      | 0                    0
      | 0                    0
      | 0                    0
      | 0      00 0000       0
      | 0     0       0      0
      | 0    0         0     0
      | 0   0           0    0
      | 00000           000000
    """

  @goalBitmapString: -> """
      |
      |     00000000000000
      |    0000000000000000
      |   000000000000000000
      |  00000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000000000000000000
      | 0000000       00000000
      | 000000         0000000
      | 00000           000000
      | 00000           000000
    """

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Pencil
  ]

  @initialize()
