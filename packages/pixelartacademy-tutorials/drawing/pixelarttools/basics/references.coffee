LOI = LandsOfIllusions
PADB = PixelArtDatabase
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.References extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.References'

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
    '/pixelartacademy/tutorials/drawing/pixelarttools/basics/susankare-brush.jpg'
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
          url: '/pixelartacademy/tutorials/drawing/pixelarttools/helpers/susankare-brush.jpg'
      ]
