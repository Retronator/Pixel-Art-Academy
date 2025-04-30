AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.OrganicShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.AssetWithReferences
  @displayName: -> "Organic shapes"
  
  @description: -> """
    Drawing characters often starts with basic shapes too.
  """
  
  @fixedDimensions: -> width: 90, height: 90
  
  @restrictedPaletteName: -> null
  
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 0, g: 0, b: 0]
      ,
        shades: [r: 0, g: 0.8, b: 1]
      ]
      
  @referenceNames: -> [
    'organicshapes-mickey'
    'organicshapes-cheshirecat'
  ]
  
  @bitmapInfoTexts: ->
    'organicshapes-mickey': "The Karnival Kid (Ub Iwerks, 1929)"
    'organicshapes-cheshirecat': "Cheshire Cat in the Tree Above Alice (Sir John Tenniel, 1889)"
  
  @initialize()
  
  bitmapInfo: ->
    assetData = @getAssetData()
    return unless assetData.stepAreas?.length

    texts = []
    
    for stepArea in assetData.stepAreas when stepArea.referenceUrl
      referenceKey = stepArea.referenceUrl.match(/\/([^\/]*)\./)[1]
      texts.push @constructor.bitmapInfoTexts()[referenceKey]
      
    return unless texts.length
      
    "Fan art study based on #{AB.Rules.English.createNounSeries texts}."

  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
    ]
    
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    steps = super arguments...
    
    # Mark construction and line art steps.
    for pathStep, index in steps
      if pathStep.paths[0].color.b
        pathStep.constructionStep = true
        pathStep.options.preserveCompleted = true
        
      else
        pathStep.lineArtStep = true
      
    # Add cleanup step.
    steps.push new PAA.Tutorials.Drawing.ElementsOfArt.Shape.CleanConstructionLinesStep @, stepArea
      
    steps
  
  Asset = @

  class @ReferencesTrayInstruction extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.ReferencesTrayInstruction
    @id: -> "#{Asset.id()}.ReferencesTrayInstruction"
    
    @assetClass: -> PAA.Tutorials.Drawing.ElementsOfArt.Shape.OrganicShapes
    @firstAssetClass: -> PAA.Tutorials.Drawing.ElementsOfArt.Shape.BasicShapesBreakdown
    
    @message: -> """
      Open the references tray and choose a character you wish to draw.
    """
    
    @priority: -> 2

    @initialize()
  
  class @ColoredShapes extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @requiredRamp: -> throw new AE.NotImplementedException "Colored shapes instruction must specify a required ramp."
    @requiredStepPropertyName: -> throw new AE.NotImplementedException "Colored shapes instruction must specify what property to check to be the correct step."
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      requiredStepPropertyName = @requiredStepPropertyName()
      
      # Show if any of the active steps are construction steps.
      for stepArea in asset.stepAreas()
        continue unless activeStep = stepArea.activeStep()
        return true if activeStep[requiredStepPropertyName]
      
      false
      
    delayDuration: ->
      defaultDelayDuration = super arguments...
      return defaultDelayDuration unless asset = @getActiveAsset()
      
      # Display immediately if there are no pixels of second ramp.
      return defaultDelayDuration unless bitmap = asset.bitmap()
      bitmapLayer = bitmap.layers[0]
      
      requiredRamp = @constructor.requiredRamp()
      
      for x in [0...bitmap.bounds.width]
        for y in [0...bitmap.bounds.height]
          continue unless pixel = bitmapLayer.getPixel x, y
          return defaultDelayDuration if pixel.paletteColor.ramp is requiredRamp
      
      0
      
  class @ConstructionShapes extends @ColoredShapes
    @id: -> "#{Asset.id()}.ConstructionShapes"
    @assetClass: -> Asset
    
    @message: -> """
      Use blue to draw the basic shapes of the character.
    """
    
    @requiredStepPropertyName: -> 'constructionStep'
    @requiredRamp: -> 1

    @priority: -> 1
  
    @initialize()
  
  class @FinalShape extends @ColoredShapes
    @id: -> "#{Asset.id()}.FinalShape"
    @assetClass: -> Asset
    
    @message: -> """
      Use black to draw the final shape of the character.
    """
    
    @requiredStepPropertyName: -> 'lineArtStep'
    @requiredRamp: -> 0
    
    @priority: -> 2

    @initialize()
  
  class @Cleanup extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Cleanup"
    @assetClass: -> Asset
    
    @message: -> """
      Remove the blue color to clean up the line art.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()

      # Show if any of the active steps are cleanup steps.
      for stepArea in asset.stepAreas() when not stepArea.completed()
        continue unless activeStep = stepArea.activeStep()
        return true if activeStep instanceof PAA.Tutorials.Drawing.ElementsOfArt.Shape.CleanConstructionLinesStep
      
      false
    
    @priority: -> 3

    @initialize()
    
    delayDuration: ->
      defaultDelayDuration = super arguments...
      return defaultDelayDuration unless asset = @getActiveAsset()
      
      # Display immediately if the last action isn't an erase step.
      return defaultDelayDuration unless bitmap = asset.bitmap()
      return defaultDelayDuration unless lastAction = bitmap.partialAction or AM.Document.Versioning.getActionAtPosition bitmap, bitmap.historyPosition - 1
      return defaultDelayDuration if lastAction.operatorId is LOI.Assets.SpriteEditor.Tools.HardEraser.id()
      
      0
