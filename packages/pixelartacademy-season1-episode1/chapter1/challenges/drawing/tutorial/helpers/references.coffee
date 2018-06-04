LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Challenges.Drawing.Tutorial.Helpers.References extends PAA.Practice.Challenges.Drawing.TutorialSprite
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.Tutorial.Helpers.References'

  @displayName: -> "References"

  @description: -> """
      Open the references tray, and grab the image to put it on your desk.
      You can resize the image by dragging at the edges.
    """

  @fixedDimensions: -> width: 7, height: 16
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black

  @bitmap: -> "" # Empty sprite

  @goalBitmap: -> """
      |   0
      |  0 0
      |  0 0
      |  0 0
      |  0 0
      |  0 0
      |  0 0
      | 0   0
      |0     0
      |0000000
      |0     0
      |0000000
      |0 0 0 0
      |0 0 000
      |0 00000
      |0000000
    """

  @references: -> [
    '/pixelartacademy/season1/episode1/chapter1/challenges/drawing/tutorial/helpers/susankare-brush.jpg'
  ]

  @spriteInfo: -> """
      Artwork by Susan Kare, 1982

      (used with permission)
    """

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
    PAA.Practice.Software.Tools.ToolKeys.Zoom
    PAA.Practice.Software.Tools.ToolKeys.References
  ]

  editorOptions: ->
    references:
      upload:
        enabled: false
      storage:
        enabled: false

  editorDrawComponents: ->
    # We send an empty array so we don't show the on-canvas reference.
    []
