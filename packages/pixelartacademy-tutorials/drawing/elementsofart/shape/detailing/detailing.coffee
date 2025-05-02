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
  ]
  
  @goalChoices: ->
    for name in @referenceNames()
      referenceUrl: "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.jpg"
      svgUrl: "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.svg"
      goalImageUrl: "/pixelartacademy/tutorials/drawing/elementsofart/shape/#{name}.png"
  
  @initialize()
  
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    svgPaths = stepResources.svgPaths.svgPaths()

    # Create basic shape steps.
    steps = for svgPath, index in svgPaths
      new @constructor.PathStep @, stepArea,
        svgPaths: [svgPath]
        preserveCompleted: true
    
    # Add detailing step.
    steps.push new @constructor.DetailingStep @, stepArea,
      goalPixels: stepResources.goalPixels
      
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
