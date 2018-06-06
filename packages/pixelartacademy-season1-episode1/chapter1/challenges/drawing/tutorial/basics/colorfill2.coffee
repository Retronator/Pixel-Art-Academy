LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Basics.ColorFill2 extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Basics.ColorFill2'

  @displayName: -> "Color fill 2"

  @description: -> """
      Use the color fill and eraser to complete the invader.
    """

  @fixedDimensions: -> width: 12, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmap: -> """
      |    0000
      | 000    000
      |0          0
      |0          0
      |000      000
      |   00  00
      |  00 00 00
      |00        00
    """

  @goalBitmap: -> """
      |    0000
      | 0000000000
      |000000000000
      |000  00  000
      |000000000000
      |   00  00
      |  00 00 00
      |00        00
    """

  @spriteInfo: -> "Artwork from Space Invaders, Taito, 1978"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Eraser
  ]

  @initialize()
