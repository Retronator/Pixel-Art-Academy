LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Colors.ColorPicking extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Colors.ColorPicking'

  @displayName: -> "Color picking"

  @description: -> """
      Click on the eyedropper and then somewhere on the drawing to pick that color.

      Shortcut: I (eye)
    """

  @fixedDimensions: -> width: 12, height: 12
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.pico8

  @bitmap: -> """
      |
      |
      |
      |
      | 8884
      |888488
      |88888
      |8788
      |8878
      | 888
      |
      |
    """

  @goalBitmap: -> """
      |          44
      |        4444
      |      44 4
      |     4   4
      | 8884   4
      |888488 4
      |88888 8488
      |8788 884888
      |8878 888888
      | 888 878888
      |     887888
      |      8888
    """

  @spriteInfo: -> "Artwork from PAC-MAN, Namco, 1980"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.ColorPicker
    PAA.Practice.Software.Tools.ToolKeys.Zoom if C1.Challenges.Drawing.Tutorial.Helpers.isAssetCompleted C1.Challenges.Drawing.Tutorial.Helpers.Zoom
  ]

  @initialize()
