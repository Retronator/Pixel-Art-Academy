LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Colors.QuickColorPicking extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Colors.QuickColorPicking'

  @displayName: -> "Quick color picking"

  @description: -> """
      When drawing with the pencil, hold down ALT to temporarily switch to color picker until ALT is released.

      ALT+click is one of the most used shortcuts in pixel art. Learn it well.
    """

  @fixedDimensions: -> width: 11, height: 12
  @restrictedPaletteName: -> PAA.Challenges.Drawing.Tutorial.Colors.pacManPaletteName
  @backgroundColor: -> LOI.Assets.Palette.defaultPalette()?.color LOI.Assets.Palette.Atari2600.hues.gray, 2

  @bitmapString: -> """
      |
      |  999
      | 1199
      |11111
      |1c111
      |111c1
      |11111
      | 1c11
      | 1111
      |  11c
      |   11
    """

  @goalBitmapString: -> """
      |     c
      |  999c999
      | 119999911
      |111119111c1
      |1c11111c111
      |111c1c11111
      |11111111c11
      | 1c11c1111
      | 111111111
      |  11c11c
      |   11111
      |     1
    """

  @bitmapInfo: -> "Artwork from PAC-MAN, Namco, 1980"

  availableToolKeys: ->
    Helpers = PAA.Challenges.Drawing.Tutorial.Helpers

    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      PAA.Practice.Software.Tools.ToolKeys.Zoom if Helpers.isAssetCompleted Helpers.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas if Helpers.isAssetCompleted Helpers.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo if Helpers.isAssetCompleted Helpers.UndoRedo
      PAA.Practice.Software.Tools.ToolKeys.Redo if Helpers.isAssetCompleted Helpers.UndoRedo
    ]

  editorStyleClasses: -> 'hidden-color-picker'

  @initialize()
