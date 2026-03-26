AE = Artificial.Everywhere
AM = Artificial.Mummification
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
    
  @markup: -> true

  @initialize()
  
  destroy: ->
    super arguments...
    
    @regions?.stop()
    @_readabilityAnalysisRegionsAutorun?.stop()
  
  _initialize: ->
    super arguments...
    
    # Update readability analysis regions based on the reference.
    @regions = new AE.LiveComputedField =>
      return unless @initialized()
      
      fixedDimensions = @constructor.fixedDimensions()
      width = fixedDimensions.width
      height = fixedDimensions.height
      
      # Create areas with target labels from step areas.
      x = 0
      
      for stepArea in @stepAreas()
        region =
          bounds: {x, y: 0, width, height}
          targetLabel: stepArea.getInformation()?.label
          
        x += width
        
        region
    ,
      EJSON.equals
    
    @_readabilityAnalysisRegionsAutorun = Tracker.autorun (computation) =>
      return unless regions = @regions()
      return unless bitmap = @bitmap()

      Tracker.nonreactive =>
        # Nothing to do if the regions are the same.
        if regions.length
          currentRegionsCount = bitmap.properties.readabilityAnalysis.regions?.length or 0
          return if regions.length is currentRegionsCount and _.objectContains bitmap.properties.readabilityAnalysis.regions, regions
          
        else
          return unless bitmap.properties.readabilityAnalysis.regions
        
        # Only update analysis when we're at the end of history to prevent recalculation when undoing/redoing
        # (in case we change analysis and this would cause new values—history is more important).
        historyLength = bitmap.history?.length or AM.Document.Versioning.ActionArchive.getHistoryLengthForDocument bitmap._id
        return unless bitmap.historyPosition is historyLength
        
        readabilityAnalysisProperty = {}
        readabilityAnalysisProperty.regions = regions if regions.length
        
        updatePropertyAction = new LOI.Assets.VisualAsset.Actions.UpdateProperty @constructor.id(), bitmap, 'readabilityAnalysis', readabilityAnalysisProperty
        bitmap.executeAction updatePropertyAction, true
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    new @constructor.DrawSomethingStep @, stepArea
    new @constructor.OpenReadabilityAnalysisStep @, stepArea
    new @constructor.PassReadabilityStep @, stepArea
  
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
  
  class @Drawing extends PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction
    activeConditions: ->
      return unless super arguments...
      
      # Show when the readability analysis is closed.
      return unless drawingEditor = @getEditor()
      return unless readabilityAnalysisView = drawingEditor.interface.getView PAA.PixelPad.Apps.Drawing.Editor.Desktop.ReadabilityAnalysis
      not readabilityAnalysisView.active()
      
    markup: ->
      return [] unless asset = @getActiveAsset()
      return [] unless stepAreas = asset.stepAreas()
      return [] unless stepAreas.length > 1
      
      markup = []
      
      style = "#aaa"
      
      lineBase =
        style: style
        width: 0
      
      textBase = _.extend {}, Markup.textBase(), {style}
      
      for stepArea, stepAreaIndex in stepAreas
        if information = stepArea.getInformation()
          markup.push
            text: _.extend {}, textBase,
              position:
                x: stepAreaIndex * 32 + 16, y: -0.5, origin: Markup.TextOriginPosition.BottomCenter
              value: information.label
        
        if stepAreaIndex
          divisionX = stepAreaIndex * 32
          
          markup.push
            line: _.extend {}, lineBase,
              points: [
                x: divisionX, y: 0
              ,
                x: divisionX, y: 32
              ]
      
      markup
  
  class @Rotate extends @Drawing
    @id: -> "#{Asset.id()}.Rotate"
    @assetClass: -> Asset
    
    @stepNumber: -> 1
    
    @message: -> """
      Convey the object in any way you want. You can rotate the reference to observe the object, but you do not have to follow it in your drawing.
    """
    
    @initialize()
    
  class @OpenReadabilityAnalysis extends @Drawing
    @id: -> "#{Asset.id()}.OpenReadabilityAnalysis"
    @assetClass: -> Asset
    
    @stepNumber: -> 2
    
    @message: -> """
      Open the readability analysis when your drawing is ready.
    """
    
    @initialize()
    
    markup: ->
      markup = super arguments...
      
      clickHereMarkup = PAA.Tutorials.Drawing.Markup.bottomRightClickHereMarkup '.pixelartacademy-pixelpad-apps-drawing-editor-desktop-readabilityanalysis', 10
      markup.push clickHereMarkup...
      
      markup
  
  class @Dividers extends @Drawing
    @id: -> "#{Asset.id()}.Dividers"
    @assetClass: -> Asset
    
    @stepNumber: -> 3
    @priority: -> -1
    
    @activeDisplayState: ->
      # We only have markup without a message.
      PAA.PixelPad.Systems.Instructions.DisplayState.Hidden
    
    @initialize()

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
