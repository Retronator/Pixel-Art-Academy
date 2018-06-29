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
  @restrictedPaletteName: -> C1.Challenges.Drawing.Tutorial.Colors.pacManPaletteName
  @backgroundColor: -> LOI.Assets.Palette.defaultPalette().color LOI.Assets.Palette.Atari2600.hues.grey, 2

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

  @spriteInfo: -> "Artwork from PAC-MAN, Namco, 1980"

  availableToolKeys: ->
    Helpers = C1.Challenges.Drawing.Tutorial.Helpers

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
