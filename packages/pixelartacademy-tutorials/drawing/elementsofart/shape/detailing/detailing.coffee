AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.ElementsOfArt.Shape.Detailing extends PAA.Tutorials.Drawing.ElementsOfArt.Shape.AssetWithReferences
  @displayName: -> "Detailing"
  
  @description: -> """
    Basic shapes form the base for creating more complex shapes and adding details.
  """
  
  @fixedDimensions: -> width: 140, height: 140
      
  @referenceNames: -> [
    'detailing-church'
    'detailing-temple'
  ]
  
  @detailingStepsCount: ->
    'detailing-church': 3
    'detailing-temple': 11
    
  @goalChoices: -> null
  
  @resources: ->
    goalChoices:
      for name in @referenceNames()
        referenceUrl: "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.jpg"
        svgPaths: new @Resource.SvgPaths "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.svg"
        goalPixels: for number in [1..@detailingStepsCount()[name]]
          new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}-#{number}.png"
  
  @initialize()
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    svgPaths = stepResources.svgPaths.svgPaths()

    # Create basic shape steps.
    steps = for svgPath in svgPaths
      new @constructor.PathStep @, stepArea,
        svgPaths: [svgPath]
        preserveCompleted: true
    
    # Add detailing step.
    for goalPixels in stepResources.goalPixels
      steps.push new @constructor.DetailingStep @, stepArea,
        goalPixels: goalPixels
        preserveCompleted: true
      
    steps
  
  Asset = @
  
  class @BasicShapes extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.BasicShapes"
    @assetClass: -> Asset
    
    @message: -> """
      Draw the indicated shapes to construct the scene from the reference
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()
      
      # Show if any of the active steps are path steps.
      for stepArea in asset.stepAreas() when not stepArea.completed()
        continue unless activeStep = stepArea.activeStep()
        return true if activeStep instanceof PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap.PathStep
      
      false
    
    @priority: -> 1

    @initialize()
  
  class @Details extends PAA.Tutorials.Drawing.Instructions.GeneralInstruction
    @id: -> "#{Asset.id()}.Details"
    @assetClass: -> Asset
    
    @message: -> """
      Add details and clean up unneeded lines to complete the drawing.
    """
    
    @activeConditions: ->
      return unless asset = @getActiveAsset()

      # Show if any of the active steps are pixel steps.
      for stepArea in asset.stepAreas() when not stepArea.completed()
        continue unless activeStep = stepArea.activeStep()
        return true if activeStep instanceof PAA.Tutorials.Drawing.ElementsOfArt.Shape.Detailing.DetailingStep
      
      false
    
    @delayOnActivate: -> false
    @priority: -> 2

    @initialize()
