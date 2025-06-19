AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtLineArt.DrawLineArt extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @displayName: -> "Draw line art"

  @description: -> """
    Demonstrate the use of pixel art rules for drawing line art.
  """

  @referenceImageUrl: -> "/pixelartacademy/challenges/drawing/pixelartlineart/#{@imageName()}.webp"

  @resources: ->
    solvePixels: new @Resource.ImagePixels "/pixelartacademy/challenges/drawing/pixelartlineart/#{@imageName()}.png"
  
  @imageName: -> throw new AE.NotImplementedException "You must provide the image name for the asset."

  @references: -> [
    image:
      url: @referenceImageUrl()
    displayOptions:
      imageOnly: true
  ]
  
  @binderScale: ->
    # Override if the reference should appear smaller than filling the entire folder.
    1
  
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black
  
  @goalChoices: -> [
    referenceUrl: @referenceImageUrl()
    svgUrl: "/pixelartacademy/challenges/drawing/pixelartlineart/#{@imageName()}.svg"
  ]

  @briefComponentClass: ->
    # Note: We need to fully qualify the name instead of using @constructor
    # since we're overriding with a class with the same name.
    PAA.Challenges.Drawing.PixelArtSoftware.CopyReference.BriefComponent
    
  @pixelArtEvaluation: -> true
  
  @properties: ->
    pixelArtScaling: true
    pixelArtEvaluation:
      unlockable: true
  
  constructor: ->
    super arguments...

    @uploadMode = new ReactiveField false
  
  # Note: We have to override initializeStepsInAreaWithResources instead of initializeSteps since
  # this will be called when creating steps after reference selection.
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    # Create a path step that has increased tolerance to allow for more freedom where you place the lines.
    svgPaths = stepResources.svgPaths.svgPaths()
  
    new @constructor.CustomSolutionPathStep @, stepArea,
      svgPaths: svgPaths
      drawHintsAfterCompleted: false
      tolerance: 2
    
  editorOptions: ->
    references:
      upload:
        enabled: false
      storage:
        enabled: false

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
    
  class @CustomSolutionPathStep extends @PathStep
    solve: ->
      bitmap = @tutorialBitmap.bitmap()
      pixels = @tutorialBitmap.resources.solvePixels.pixels()
      
      # Replace the layer pixels in this bitmap.
      strokeAction = new LOI.Assets.Bitmap.Actions.Stroke @tutorialBitmap.id(), bitmap, [0], pixels
      AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, strokeAction, new Date

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
