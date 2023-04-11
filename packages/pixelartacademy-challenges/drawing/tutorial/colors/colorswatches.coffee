LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Colors.ColorSwatches extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Colors.ColorSwatches'

  @displayName: -> "Color swatches"

  @description: -> """
      Use the color swatches to change between colors.
    """

  @fixedDimensions: -> width: 14, height: 14
  @restrictedPaletteName: -> PAA.Challenges.Drawing.Tutorial.Colors.pacManPaletteName
  @backgroundColor: -> LOI.Assets.Palette.defaultPalette().color LOI.Assets.Palette.Atari2600.hues.gray, 2

  @goalBitmapString: -> """
      |     4444
      |   44444444
      |  4444444444
      | 444cc4444cc4
      | 44cccc44cccc
      | 44cc8844cc88
      |444cc8844cc884
      |4444cc4444cc44
      |44444444444444
      |44444444444444
      |44444444444444
      |44444444444444
      |4444 4444 4444
      | 44   44   44
    """

  @bitmapInfo: -> "Artwork from PAC-MAN, Namco, 1980"

  availableToolKeys: ->
    Helpers = PAA.Challenges.Drawing.Tutorial.Helpers

    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      PAA.Practice.Software.Tools.ToolKeys.Zoom if Helpers.isAssetCompleted Helpers.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas if Helpers.isAssetCompleted Helpers.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo if Helpers.isAssetCompleted Helpers.UndoRedo
      PAA.Practice.Software.Tools.ToolKeys.Redo if Helpers.isAssetCompleted Helpers.UndoRedo
    ]

  @initialize()
