AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.OrganicShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.AssetWithReferences
  @displayName: -> "Organic shapes"
  
  @description: -> """
    Drawing basic shapes in a lighter color can serve as a placement guide.
  """
  
  @fixedDimensions: -> width: 80, height: 80
  
  @restrictedPaletteName: -> null
  
  @customPalette: ->
    new LOI.Assets.Palette
      ramps: [
        shades: [r: 0, g: 0, b: 0]
      ,
        shades: [r: 0, g: 0.8, b: 1]
      ]
      
  @referenceNames: -> [
    'organicshapes-tree'
    'organicshapes-plants'
  ]
  
  @detailingStepsCount: ->
    'organicshapes-tree': 8
    'organicshapes-plants': 13
    
  @goalChoices: -> null
  
  @resources: ->
    goalChoices:
      for name in @referenceNames()
        referenceUrl: "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.jpg"
        svgPaths: new @Resource.SvgPaths "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.svg"
        goalPixels: for number in [1..@detailingStepsCount()[name]]
          new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}-#{number}.png"
  
  @initialize()
  
  availableToolKeys: ->
    super(arguments...).concat [
      PAA.Practice.Software.Tools.ToolKeys.ColorPicker
      PAA.Practice.Software.Tools.ToolKeys.ColorSwatches
      PAA.Practice.Software.Tools.ToolKeys.ColorFill
    ]
    
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    svgPaths = stepResources.svgPaths.svgPaths()
    
    # Create basic shape steps.
    steps = for svgPath in svgPaths
      new PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.PathStep @, stepArea,
        svgPaths: [svgPath]
        preserveCompleted: true
        constructionStep: true
        
    # Add detailing steps.
    for goalPixels in stepResources.goalPixels
      steps.push new PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.PixelsStep @, stepArea,
        goalPixels: goalPixels
        lineArtStep: true
      
    # Add cleanup step.
    steps.push new PAA.Tutorials.Drawing.ElementsOfArt.Shape.CleanConstructionLinesStep @, stepArea
    
    steps
  
  Asset = @

  class @ConstructionShapes extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.RequiredRampInstruction
    @id: -> "#{Asset.id()}.ConstructionShapes"
    @assetClass: -> Asset
    
    @message: -> """
      Use blue to roughly mark where the bigger parts of the object are placed in the image.
    """
    
    @requiredStepPropertyName: -> 'constructionStep'
    @requiredRamp: -> 1

    @priority: -> 1
  
    @initialize()
  
  class @FinalShape extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.RequiredRampInstruction
    @id: -> "#{Asset.id()}.FinalShape"
    @assetClass: -> Asset
    
    @message: -> """
      Use black to draw the final shape of the object.
    """
    
    @requiredStepPropertyName: -> 'lineArtStep'
    @requiredRamp: -> 0
    
    @priority: -> 2

    @initialize()
