AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.OrganicShapes2 extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.AssetWithReferences
  @displayName: -> "Organic shapes 2"
  
  @description: -> """
    Drawing characters often starts with basic shapes too.
  """
  
  @fixedDimensions: -> width: 90, height: 90
  @backgroundColor: -> new THREE.Color '#e8cfb7'
  @restrictedPaletteName: -> null
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 0, g: 0, b: 0]
      ,
        shades: [r: 0, g: 0.6, b: 1]
      ]
      
  @referenceNames: -> [
    'organicshapes2-mickey'
    'organicshapes2-cheshirecat'
  ]
  
  @bitmapInfoTexts: ->
    'organicshapes2-mickey': "The Karnival Kid (Ub Iwerks, 1929)"
    'organicshapes2-cheshirecat': "Cheshire Cat in the Tree Above Alice (Sir John Tenniel, 1889)"
  
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
      if pathStep.paths[0].strokeColor.b
        pathStep.options.constructionStep = true
        pathStep.options.preserveCompleted = true
        
      else
        pathStep.options.lineArtStep = true
      
    # Add cleanup step.
    steps.push new PAA.Tutorials.Drawing.ElementsOfArt.Shape.CleanConstructionLinesStep @, stepArea
      
    steps
  
  Asset = @

  class @ReferencesTrayInstruction extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.ReferencesTrayInstruction
    @id: -> "#{Asset.id()}.ReferencesTrayInstruction"
    
    @assetClass: -> PAA.Tutorials.Drawing.ElementsOfArt.Shape.OrganicShapes2
    @firstAssetClass: -> PAA.Tutorials.Drawing.ElementsOfArt.Shape.BasicShapesBreakdown
    
    @message: -> """
      Open the references tray and choose a character you wish to draw.
    """
    
    @priority: -> 2

    @initialize()
  
  class @ConstructionShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.RequiredRampInstruction
    @id: -> "#{Asset.id()}.ConstructionShapes"
    @assetClass: -> Asset
    
    @message: -> """
      Use blue to draw the basic shapes of the character.
    """
    
    @requiredStepPropertyName: -> 'constructionStep'
    @requiredRamp: -> 1

    @priority: -> 1
  
    @initialize()
  
  class @FinalShape extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.RequiredRampInstruction
    @id: -> "#{Asset.id()}.FinalShape"
    @assetClass: -> Asset
    
    @message: -> """
      Use black to draw the final shape of the character.
    """
    
    @requiredStepPropertyName: -> 'lineArtStep'
    @requiredRamp: -> 0
    
    @priority: -> 2

    @initialize()
