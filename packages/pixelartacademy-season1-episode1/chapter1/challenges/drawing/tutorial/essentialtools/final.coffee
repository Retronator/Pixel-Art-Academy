LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.EssentialTools.Final extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.EssentialTools.Final'

  @displayName: -> "Basic tools"

  @description: -> """
      Use the pencil, color fill, and eraser to demonstate your use of basic drawing tools.
    """

  @fixedDimensions: -> width: 16, height: 7
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmap: -> """
      |     000000
      |   00      00
      |  0          0
      | 0            0
      |0000000000000000
    """

  @goalBitmap: -> """
      |     000000
      |   0000000000
      |  000000000000
      | 00 00 00 00 00
      |0000000000000000
      |  000  00  000
      |   0        0
    """

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
  ]

  @initialize()
