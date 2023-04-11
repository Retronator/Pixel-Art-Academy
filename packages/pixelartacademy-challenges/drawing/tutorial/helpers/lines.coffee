LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Helpers.Lines extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Helpers.Lines'

  @displayName: -> "Lines"

  @description: -> """
      With the pencil tool, hold shift to draw a line from the previous pixel to the current one.
      Hold also cmd/ctrl to constrain the line to perfect diagonals.
    """

  @fixedDimensions: -> width: 57, height: 32
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @goalImageUrl: ->
    "/pixelartacademy/challenges/drawing/tutorial/helpers/720-goal.png"

  @bitmapInfo: -> "Artwork from 720° (ZX Spectrum), Atari, 1987"

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
    PAA.Practice.Software.Tools.ToolKeys.Undo
    PAA.Practice.Software.Tools.ToolKeys.Redo
  ]
