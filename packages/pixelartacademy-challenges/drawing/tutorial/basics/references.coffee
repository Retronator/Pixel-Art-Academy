LOI = LandsOfIllusions
PADB = PixelArtDatabase
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.Tutorial.Basics.References extends PAA.Practice.Challenges.Drawing.TutorialBitmap
  @id: -> 'PixelArtAcademy.Challenges.Drawing.Tutorial.Basics.References'

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

  @bitmapString: -> "" # Empty bitmap

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
    '/pixelartacademy/challenges/drawing/tutorial/helpers/susankare-brush.jpg'
  ]

  @bitmapInfo: -> """
      Artwork by Susan Kare, 1982

      (used with permission)
    """

  @initialize()

  availableToolKeys: -> [
    PAA.Practice.Software.Tools.ToolKeys.Pencil
    PAA.Practice.Software.Tools.ToolKeys.Eraser
    PAA.Practice.Software.Tools.ToolKeys.ColorFill
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
          url: '/pixelartacademy/challenges/drawing/tutorial/helpers/susankare-brush.jpg'
      ]
