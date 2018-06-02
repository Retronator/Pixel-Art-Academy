LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

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
