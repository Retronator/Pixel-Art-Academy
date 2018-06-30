LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Colors.ColorPicking extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Colors.ColorPicking'

  @displayName: -> "Color picking"

  @description: -> """
      Click on the eyedropper and then somewhere on the drawing to pick that color.

      Shortcut: I (eyedropper)
    """

  @fixedDimensions: -> width: 12, height: 12
  @restrictedPaletteName: -> C1.Challenges.Drawing.Tutorial.Colors.pacManPaletteName
  @backgroundColor: -> LOI.Assets.Palette.defaultPalette().color LOI.Assets.Palette.Atari2600.hues.grey, 2

  @bitmapString: -> """
      |
      |
      |
      |
      | 1112
      |111211
      |11111
      |1c11
      |11c1
      | 111
      |
      |
    """

  @goalBitmapString: -> """
      |          22
      |        2222
      |      22 2
      |     2   2
      | 1112   2
      |111211 2
      |11111 1211
      |1c11 112111
      |11c1 111111
      | 111 1c1111
      |     11c111
      |      1111
    """

  @spriteInfo: -> "Artwork from PAC-MAN, Namco, 1980"

  availableToolKeys: ->
    Helpers = C1.Challenges.Drawing.Tutorial.Helpers
    
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

  @initialize()
