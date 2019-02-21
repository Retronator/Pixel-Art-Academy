LOI = LandsOfIllusions
PADB = PixelArtDatabase
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
  @customPalette: ->
    ramps: [
      shades: [r: 0.95, g: 0.30, b: 0.5]
    ]

  @bitmapString: -> "" # Empty sprite

  @goalBitmapString: -> """
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
    PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
    PAA.Practice.Software.Tools.ToolKeys.References
    PAA.Practice.Software.Tools.ToolKeys.Undo
    PAA.Practice.Software.Tools.ToolKeys.Redo
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

if Meteor.isServer
  Document.startup ->
    return if Meteor.settings.startEmpty

    PADB.create
      artist:
        name:
          first: 'Susan'
          last: 'Kare'
      artworks: [
        type: PADB.Artwork.Types.Physical
        name: 'Brush'
        completionDate:
          year: 1982
        image:
          url: '/pixelartacademy/season1/episode1/chapter1/challenges/drawing/tutorial/helpers/susankare-brush.jpg'
      ]
