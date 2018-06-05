LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Colors.ColorSwatches extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Colors.ColorSwatches'

  @displayName: -> "Color swatches"

  @description: -> """
      Use the color swatches to change between colors.
    """

  @fixedDimensions: -> width: 14, height: 14
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.pico8

  @bitmap: -> "" # Empty sprite

  @goalBitmap: -> """
      |     cccc
      |   cccccccc
      |  cccccccccc
      | ccc77cccc77c
      | cc7777cc7777
      | cc7711cc7711
      |ccc7711cc7711c
      |cccc77cccc77cc
      |cccccccccccccc
      |cccccccccccccc
      |cccccccccccccc
      |cccccccccccccc
      |cccc cccc cccc
      | cc   cc   cc
    """

  @spriteInfo: -> "Artwork from PAC-MAN, Namco, 1980"

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
    PAA.Practice.Software.Tools.ToolKeys.Zoom if C1.Challenges.Drawing.Tutorial.Helpers.isAssetCompleted C1.Challenges.Drawing.Tutorial.Helpers.Zoom
  ]

  @initialize()
