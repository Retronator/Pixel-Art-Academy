LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.Shortcuts extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.Shortcuts'

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

  @bitmapInfo: -> "Artwork from Space Invaders, Taito, 1978"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
  ]

  editorStyleClasses: -> 'hidden-tools'

  @initialize()
