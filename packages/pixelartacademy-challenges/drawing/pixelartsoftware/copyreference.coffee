AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtSoftware.CopyReference extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @displayName: -> "Copy the reference"

  @description: -> """
      Recreate the provided reference to show you know how to use pixel art software.
    """

  @bitmap: -> "" # Empty bitmap

  @goalImageUrl: -> "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@imageName()}.png"

  @imageName: -> throw new AE.NotImplementedException "You must provide the image name for the asset."

  @references: -> [
    image:
      url: "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@imageName()}-reference.png"
    displayOptions:
      imageOnly: true
  ]

  @customPaletteImageUrl: ->
    return null if @restrictedPaletteName()

    "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@imageName()}-template.png"

  @briefComponentClass: ->
    # Note: We need to fully qualify the name instead of using @constructor
    # since we're overriding with a class with the same name.
    PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent
  
  constructor: ->
    super arguments...

    @uploadMode = new ReactiveField false

    @_clipboardSecondPageComponent = new PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.ClipboardSecondPageComponent @
  
  initializeSteps: ->
    super arguments...
    
    # Make the pixels step only show drawn errors.
    @stepAreas()[0].steps()[0].options.drawHintsForGoalPixels = false
    
  editorOptions: ->
    references:
      upload:
        enabled: false
      storage:
        enabled: false

  clipboardSecondPageComponent: ->
    # We only show this page if we can upload.
    return unless PAA.PixelPad.Apps.Drawing.state('externalSoftware')?
    
    @_clipboardSecondPageComponent

  availableToolKeys: ->
    # When we're in upload mode, don't show any tools in the editor.
    return [] if @uploadMode()
    
    # Otherwise, show all basic tools.
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
      PAA.Practice.Software.Tools.ToolKeys.References
    ]

  templateUrl: ->
    "/pixelartacademy/challenges/drawing/pixelartsoftware/#{@constructor.imageName()}-template.png"

  referenceUrl: ->
    @constructor.references()[0].image.url
