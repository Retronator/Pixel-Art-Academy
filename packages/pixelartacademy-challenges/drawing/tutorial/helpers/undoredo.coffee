LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Helpers.UndoRedo extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Helpers.UndoRedo'

  @displayName: -> "Undo/redo"

  @description: -> """
      Complete the dithering pattern on the CodeMasters logo. If you make a mistake, use the undo button
      under the pencil. Shortcuts:

      - Cmd/ctrl + Z: undo
      - Cmd/ctrl + shift + Z: redo
    """

  @fixedDimensions: -> width: 59, height: 59
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black
  @maxClipboardScale: -> 1

  @imageUrl: ->
    "/pixelartacademy/challenges/drawing/tutorial/helpers/codemasters.png"

  @goalImageUrl: ->
    "/pixelartacademy/challenges/drawing/tutorial/helpers/codemasters-goal.png"

  @bitmapInfo: -> "CodeMasters logo from the loading screen of Fast Food (ZX Spectrum), 1989"

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
    PAA.Practice.Software.Tools.ToolKeys.Undo
    PAA.Practice.Software.Tools.ToolKeys.Redo
  ]

  minClipboardScale: -> 1
