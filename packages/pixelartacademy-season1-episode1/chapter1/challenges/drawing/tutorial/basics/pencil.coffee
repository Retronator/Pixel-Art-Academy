LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Basics.Pencil extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Basics.Pencil'

  @displayName: -> "Pencil"

  @description: -> """
      Using the pencil, fill the pixels with the dot in the middle.
      Click start when you're ready. If you make a mistake, come back and reset the challenge.
    """

  @fixedDimensions: -> width: 8, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmap: -> "" # Empty sprite

  @goalBitmap: -> """
      |   00
      |  0000
      | 000000
      |00 00 00
      |00000000
      | 0 00 0
      |0      0
      | 0    0
    """

  @spriteInfo: -> "Artwork from Space Invaders, Taito, 1978"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
  ]

  @initialize()
