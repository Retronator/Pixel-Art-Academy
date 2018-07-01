LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Helpers.MoveCanvas extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Helpers.MoveCanvas'

  @displayName: -> "Move image"

  @description: -> """
      Press the H key or hold down the spacebar to activate the hand cursor.
      Click and drag to move the image around the table.

      Shortcut: H (hand)

      Quick shortcut: space
    """

  @fixedDimensions: -> width: 256, height: 32
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @imageUrl: ->
    "pixelartacademy/season1/episode1/chapter1/challenges/drawing/tutorial/helpers/outrun-hills.png"

  @goalImageUrl: ->
    "pixelartacademy/season1/episode1/chapter1/challenges/drawing/tutorial/helpers/outrun-hills-goal.png"

  @spriteInfo: -> "Artwork from Out Run (ZX Spectrum), Probe Software, 1987"

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
  ]

  minClipboardScale: -> 1
