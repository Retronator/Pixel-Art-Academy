LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.ColorTools.ColorPicking extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.ColorTools.ColorPicking'

  @displayName: -> "Color picking"

  @description: -> """
      Click on the eyedropper and then somewhere on the drawing to pick that color.
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

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.ColorPicker
  ]

  @initialize()

class C1.Challenges.Drawing.Tutorial.ColorTools.ColorPickingShortcuts extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.ColorTools.ColorPickingShortcuts'

  @displayName: -> "Color picking shortcuts"

  @description: -> """
      There are two shortcuts for activating the color picker:

      - I: color picker (eye dropper)
      - ALT: temporarily switch to color picker until released

      ALT+click is one of the most used shortcuts in pixel art. Learn it well.
    """

  @fixedDimensions: -> width: 11, height: 12
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.pico8

  @bitmap: -> """
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

  @goalBitmap: -> """
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

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.ColorPicker
  ]

  @initialize()
