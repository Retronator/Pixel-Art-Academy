AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtLineArt.DrawLineArt extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @displayName: -> "Draw line art"

  @description: -> """
    Demonstrate the use of pixel art rules for drawing line art.
  """

  @svgUrl: -> "/pixelartacademy/challenges/drawing/pixelartlineart/#{@imageName()}.svg"
  @referenceImageUrl: -> "/pixelartacademy/challenges/drawing/pixelartlineart/#{@imageName()}.webp"

  @imageName: -> throw new AE.NotImplementedException "You must provide the image name for the asset."

  @references: -> [
    image:
      url: @referenceImageUrl()
    displayOptions:
      imageOnly: true
  ]
  
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black
  
  @goalChoices: -> [
    referenceUrl: @referenceImageUrl()
    svgUrl: @svgUrl()
  ]

  @briefComponentClass: ->
    # Note: We need to fully qualify the name instead of using @constructor
    # since we're overriding with a class with the same name.
    PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent
    
  @pixelArtEvaluation: -> true
  
  constructor: ->
    super arguments...

    @uploadMode = new ReactiveField false

    @_clipboardPageComponent = new PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.ClipboardPageComponent @
  
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

  clipboardPageComponent: ->
    # We only show this page if we can upload.
    return unless PAA.PixelPad.Apps.Drawing.state('externalSoftware')?
    
    @_clipboardPageComponent

  availableToolKeys: ->
    # When we're in upload mode, don't show any tools in the editor.
    return [] if @uploadMode()
    
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
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

    ###
  class @EnableEvaluation extends PAA.PixelPad.Systems.Instructions.Instruction
    @criterion: -> throw new AE.NotImplementedException "You must provide which pixel art evaluation criterion this challenge unlocks."

    @activeDisplayState: ->
      # We only want a pop-up without a normal instruction message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show when the asset is completed.
      asset.completed()
    
    @initialize()
    
    onActivate: ->
      super arguments...
      
      criterion = Asset.criterion()
      criterionName = PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation.Overview.CriteriaNames[criterion]
      
      dialog = new LOI.Components.Dialog
        message: """
            Well done! You now have access to evaluation #{_.toLower criterionName} in previous pixel art tutorials.
            Do you want to automatically turn it on for relevant lessons?
          """
        moreInfo: "You can come back to this challenge to enable it at a later point."
        buttons: [
          text: "Yes"
          value: true
        ,
          text: "No"
        ]
      
      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          return unless dialog.result

          PAA.Tutorials.Drawing.PixelArtFundamentals.enablePixelArtEvaluation criterion
    
###

