LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Basics.Shortcuts extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Basics.Shortcuts'

  @displayName: -> "Shortcuts"

  @description: -> """
      Quickly switch between tools by using keyboard shortcuts:

      - B: pencil (brush)
      - E: eraser
      - G: color fill (gradient)
    """

  @fixedDimensions: -> width: 12, height: 8
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmapString: -> """
      |
      |
      |  00000000
      | 0        0
      |0          0
      |000000000000
    """

  @goalBitmapString: -> """
      |  0      0
      |   0    0
      |  00000000
      | 00 0000 00
      |000000000000
      |0 00000000 0
      |0 0      0 0
      |   00  00
    """

  @spriteInfo: -> "Artwork from Space Invaders, Taito, 1978"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
  ]

  editorStyleClasses: -> 'hidden-tools'

  @initialize()
