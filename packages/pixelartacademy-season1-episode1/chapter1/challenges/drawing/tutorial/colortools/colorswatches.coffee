LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.ColorTools.ColorSwatches extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.ColorTools.ColorSwatches'

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

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
  ]

  @initialize()
