LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Helpers.UndoRedo extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Helpers.UndoRedo'

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
    "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/tutorial/helpers/codemasters.png"

  @goalImageUrl: ->
    "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/tutorial/helpers/codemasters-goal.png"

  @spriteInfo: -> "CodeMasters logo from the loading screen of Fast Food (ZX Spectrum), 1989"

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
    PAA.Practice.Software.Tools.ToolKeys.Undo
    PAA.Practice.Software.Tools.ToolKeys.Redo
  ]

  minClipboardScale: -> 1
