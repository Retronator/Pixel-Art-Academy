AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup

class PAA.Tutorials.Drawing.PixelArtFundamentals.Size.ReadabilityAnalysis extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Size.ReadabilityAnalysis"
  
  @displayName: -> "Readability analysis"
  
  @description: -> """
    Test if the computer can recognize your pixel art with the readability analysis.
  """
  
  @fixedDimensions: -> width: 32, height: 32
  @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Black
  
  @references: -> [
    image:
      url: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/readabilityanalysis-alarmclock.glb"
    displayOptions:
      type: PAA.PixelPad.Apps.Drawing.Editor.ReferenceDisplayTypes.Model
      input:
        rotate: true
      background:
        color: "#808080"
      environment:
        url: "/artificial/spectrum/environments/polyhaven/studio_small_08_1k.hdr"
      camera:
        fieldOfView: 40
        radialDistance: 0.3
        azimuthalAngle: AR.Degrees -20
        polarAngle: AR.Degrees 70
        zNear: 0.1
        zFar: 0.5
      exposureValue: -0.5
  ]
  
  @referenceNames: -> ["alarmclock"]
  
  @goalChoices: ->
    for name in @referenceNames()
      referenceUrl: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/readabilityanalysis-#{name}.glb"
      information:
        label: name
        
  @pixelArtEvaluation: -> true
  @readabilityAnalysis: -> true
  
  @properties: ->
    pixelArtScaling: true
    readabilityAnalysis: true

  @initialize()
  
  availableToolKeys: ->
    [
      PAA.Practice.Software.Tools.ToolKeys.Pencil
      PAA.Practice.Software.Tools.ToolKeys.Eraser
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
      PAA.Practice.Software.Tools.ToolKeys.Zoom
      PAA.Practice.Software.Tools.ToolKeys.MoveCanvas
      PAA.Practice.Software.Tools.ToolKeys.Undo
      PAA.Practice.Software.Tools.ToolKeys.Redo
      PAA.Practice.Software.Tools.ToolKeys.Line
      PAA.Practice.Software.Tools.ToolKeys.Rectangle
      PAA.Practice.Software.Tools.ToolKeys.Ellipse
      PAA.Practice.Software.Tools.ToolKeys.References
    ]
    
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    new @constructor.OpenReadabilityAnalysisStep @, stepArea,
      label: stepResources.information.label
      
    new @constructor.DrawingStep @, stepArea,
      label: stepResources.information.label
  
  Asset = @
  
  class @OpenReadabilityAnalysisStep extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      # Readability analysis needs to be open.
      return unless drawingEditor = @getEditor()
      return unless pixelArtEvaluationView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.PixelArtEvaluation
      pixelArtEvaluationView.active()
  
  class @DrawingStep extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.Step
    completed: ->
      readabilityAnalysis = @stepArea.tutorialBitmap.readabilityAnalysis()
      
      # TODO: Check if the classifier thinks the subject is correct.
      false
      
  class @ReferencesTrayInstruction extends PAA.Tutorials.Drawing.Instructions.ReferencesTrayInstruction
    @id: -> "#{Asset.id()}.ReferencesTrayInstruction"
    
    @assetClass: -> Asset
    @firstAssetClass: -> Asset
    
    @message: -> """
      Open the references tray and choose an object you wish to draw.
    """
    
    @initialize()
  
  class @HasPixelsInstruction extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    @stepNumber: -> 1
    
    hasPixels: ->
      return unless asset = @getActiveAsset()
      return unless @stepAreaActive()
      return unless stepArea = @getStepArea()
      
      # Show until anything has been drawn.
      bitmap = asset.bitmap()
      
      for x in [stepArea.bounds.x...stepArea.bounds.x + stepArea.bounds.width]
        for y in [stepArea.bounds.y...stepArea.bounds.y + stepArea.bounds.height]
          if bitmap.findPixelAtAbsoluteCoordinates x, y
            return true
      
      false
    
  class @Rotate extends @HasPixelsInstruction
    @id: -> "#{Asset.id()}.Rotate"
    @assetClass: -> Asset
    
    @message: -> """
      Convey the object in any way you want. You can rotate the reference to observe the object, but you do not have to follow it in your drawing.
    """
    
    @initialize()
    
    activeConditions: ->
      hasPixels = @hasPixels()
      return unless hasPixels?

      not hasPixels
  
  class @OpenReadabilityAnalysis extends @HasPixelsInstruction
    @id: -> "#{Asset.id()}.OpenReadabilityAnalysis"
    @assetClass: -> Asset
    
    @message: -> """
      Open the readability analysis when your drawing is ready.
    """
    
    @initialize()
    
    activeConditions: -> @hasPixels()
