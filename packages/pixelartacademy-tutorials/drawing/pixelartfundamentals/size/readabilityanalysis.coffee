AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Atari2600 = LOI.Assets.Palette.Atari2600
Markup = PAA.Practice.Helpers.Drawing.Markup
InstructionsSystem = PAA.PixelPad.Systems.Instructions

class PAA.Tutorials.Drawing.PixelArtFundamentals.Size.ReadabilityAnalysis extends PAA.Tutorials.Drawing.PixelArtFundamentals.Size.AssetWithReferences
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
  ,
    image:
      url: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/readabilityanalysis-bicycle.glb"
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
        radialDistance: 2.8
        azimuthalAngle: AR.Degrees -60
        polarAngle: AR.Degrees 70
        zNear: 0.1
        zFar: 5
      exposureValue: -0.5
  ,
    image:
      url: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/readabilityanalysis-umbrella.glb"
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
        radialDistance: 2.5
        azimuthalAngle: AR.Degrees 80
        polarAngle: AR.Degrees 110
        zNear: 0.1
        zFar: 5
      exposureValue: -0.5
  ]
  
  @labels: -> ['alarm clock', 'bicycle', 'umbrella']
  
  @goalChoices: ->
    for label in @labels()
      referenceUrl: "/pixelartacademy/tutorials/drawing/pixelartfundamentals/size/readabilityanalysis-#{_.fileCase label}.glb"
      information: {label}
        
  @readabilityAnalysis: -> true
  
  @properties: ->
    pixelArtScaling: true
    readabilityAnalysis: {}

  @initialize()
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    new @constructor.DrawSomethingStep @, stepArea
    new @constructor.OpenReadabilityAnalysisStep @, stepArea
    new @constructor.PassReadabilityStep @, stepArea
  
  readabilityAnalysisOptions: ->
    fixedDimensions = @constructor.fixedDimensions()
    width = fixedDimensions.width
    height = fixedDimensions.height
    horizontalExtension = @constructor.canvasExtensionDirection() is @constructor.CanvasExtensionDirection.Horizontal
  
    regions: =>
      return unless @initialized()
      
      # Create areas with target labels from step areas.
      x = 0
      y = 0
      
      for stepArea in @stepAreas()
        region =
          bounds: {x, y, width, height}
          label: stepArea.getInformation()?.label
          
        if horizontalExtension
          x += width
          
        else
          y += height
          
        region
  
  Asset = @
  
  class @DrawSomethingStep extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.Step
    # Any pixels are valid to draw.
    hasPixel: -> true
    
    completed: ->
      return unless bitmap = @stepArea.tutorialBitmap.bitmap()
      
      for x in [@stepArea.bounds.x...@stepArea.bounds.x + @stepArea.bounds.width]
        for y in [@stepArea.bounds.y...@stepArea.bounds.y + @stepArea.bounds.height]
          if bitmap.findPixelAtAbsoluteCoordinates x, y
            return true
      
      false
  
  class @OpenReadabilityAnalysisStep extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.EphemeralStep
    completed: ->
      return true if super arguments...
      
      # Readability analysis needs to be open.
      return unless drawingEditor = @getEditor()
      return unless readabilityAnalysisView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.ReadabilityAnalysis
      readabilityAnalysisView.active()

  class @PassReadabilityStep extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.Step
    completed: -> @stepArea.tutorialBitmap.bitmap()?.properties.readabilityAnalysis.passes
      
  class @ReferencesTrayInstruction extends PAA.Tutorials.Drawing.Instructions.ReferencesTrayInstruction
    @id: -> "#{Asset.id()}.ReferencesTrayInstruction"
    
    @assetClass: -> Asset
    @firstAssetClass: -> Asset
    
    @message: -> """
      Open the references tray and choose an object you wish to draw.
    """
    
    @initialize()
  
  class @Rotate extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    @id: -> "#{Asset.id()}.Rotate"
    @assetClass: -> Asset
    
    @stepNumber: -> 1
    
    @message: -> """
      Convey the object in any way you want. You can rotate the reference to observe the object, but you do not have to follow it in your drawing.
    """
    
    @initialize()
    
  class @OpenReadabilityAnalysis extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    @id: -> "#{Asset.id()}.OpenReadabilityAnalysis"
    @assetClass: -> Asset
    
    @stepNumber: -> 2
    
    @message: -> """
      Open the readability analysis when your drawing is ready.
    """
    
    @initialize()
    
    markup: -> PAA.Tutorials.Drawing.Markup.bottomRightClickHereMarkup '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-readabilityanalysis', 10

  class @ReadabilityAnalysisDescription extends PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction
    @passes: -> throw new AE.NotImplementedException "Readability analysis description must say whether it should be displayed when passed or not."
    @assetClass: -> Asset
    
    @displaySide: -> InstructionsSystem.DisplaySide.Top
    @delayDuration: -> 3

    activeConditions: ->
      # Show when the readability analysis is open.
      return unless drawingEditor = @getEditor()
      return unless readabilityAnalysisView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.ReadabilityAnalysis
      return unless readabilityAnalysisView.active()
      
      # Show when the readability analysis has the correct passes state.
      return unless asset = @getActiveAsset()
      asset.bitmap()?.properties.readabilityAnalysis.passes is @constructor.passes()
  
  class @ReadabilityAnalysisFail extends @ReadabilityAnalysisDescription
    @id: -> "#{Asset.id()}.ReadabilityAnalysisFail"
    
    @passes: -> false
    
    @message: -> """
        Pixeltosh has performed an analysis of what it can see.
        Since it's an old computer, it's not very good at seeing like a human does.
        Don't take its assessment too seriously.
        
        Still, you can improve the clarity of your drawing to discern it from other possibilities.
      """
    
    @initialize()
    
  class @ReadabilityAnalysisPass extends @ReadabilityAnalysisDescription
    @id: -> "#{Asset.id()}.ReadabilityAnalysisPass"

    @passes: -> true
    
    @message: -> """
        Pixeltosh has performed an analysis of what it can see.
        Since it's an old computer, it's not very good at seeing like a human does.
        Don't take its assessment too seriously.
        
        Still, your drawing is clear enough that it was able to detect the subject correctly.
      """

    @initialize()
