LOI = LandsOfIllusions
PADB = PixelArtDatabase
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Basics.References extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> 'PixelArtAcademy.Tutorials.Drawing.PixelArtTools.Basics.References'

  @displayName: -> "References"

  @description: -> """
      Reference images will be very important throughout your
      creative journey to draw more accurate and believable images.
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
    
  Asset = @

  class @Tray extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Tray"
    @assetClass: -> Asset
    
    @message: -> """
        Open the references tray and grab the image to put it on your desk.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show until the image has a displayed reference.
      bitmap = asset.bitmap()
      not bitmap.references[0].displayed
  
    @delayDuration: -> @defaultDelayDuration
    
    @initialize()
    
  class @Resize extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Resize"
    @assetClass: -> Asset
    
    @message: -> """
        You can resize the reference by dragging its edges.
      """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show after the image has a reference, until a reference resize step has been added.
      bitmap = asset.bitmap()
      return unless bitmap.references[0].displayed
      
      scaleOperationsCount = 0
      
      for action in bitmap.history
        for operation in action.forward
          scaleOperationsCount++ if operation instanceof LOI.Assets.VisualAsset.Operations.UpdateReference and operation.changes.scale
  
      # We need at least 2 scale operations since displaying the reference will automatically create one.
      scaleOperationsCount < 2
  
    @delayDuration: -> @defaultDelayDuration
    
    @initialize()
    
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
