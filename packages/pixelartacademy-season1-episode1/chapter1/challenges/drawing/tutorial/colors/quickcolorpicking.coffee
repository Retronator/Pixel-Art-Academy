LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Colors.QuickColorPicking extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Colors.QuickColorPicking'

  @displayName: -> "Quick color picking"

  @description: -> """
      When drawing with the pencil, hold down ALT to temporarily switch to color picker until ALT is released.

      ALT+click is one of the most used shortcuts in pixel art. Learn it well.
    """

  @fixedDimensions: -> width: 11, height: 12
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.pico8

  @bitmapString: -> """
      |
      |  333
      | 8833
      |88888
      |87888
      |88878
      |88888
      | 8788
      | 8888
      |  887
      |   88
    """

  @goalBitmapString: -> """
      |     7
      |  3337333
      | 883333388
      |88888388878
      |87888887888
      |88878788888
      |88888888788
      | 878878888
      | 888888888
      |  887887
      |   88888
      |     8
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
