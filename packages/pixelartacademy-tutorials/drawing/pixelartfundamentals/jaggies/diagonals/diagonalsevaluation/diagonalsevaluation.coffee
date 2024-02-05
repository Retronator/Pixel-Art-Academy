LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation
StraightLine = PAE.Line.Part.StraightLine

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.DiagonalsEvaluation extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.DiagonalsEvaluation"

  @displayName: -> "Diagonals evaluation"
  
  @description: -> """
    Learn how the pixel art evaluation paper can help you identify types of diagonals.
  """
  
  @fixedDimensions: -> width: 30, height: 29
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/diagonalsevaluation.svg"
  @breakPathsIntoSteps: -> true
  @drawHintsAfterCompleted: -> false
  
  @markup: -> true
  @pixelArtEvaluation: -> true

  @properties: ->
    pixelArtScaling: true
    pixelArtEvaluation:
      allowedCriteria: [PAE.Criteria.EvenDiagonals]
      evenDiagonals:
        segmentLengths: {}
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    # Modify existing and add additional, non-drawing tutorial steps.
    stepArea = @stepAreas()[0]
    pathSteps = _.clone stepArea.steps()
    
    for pathStep in pathSteps
      pathStep.options.drawHintsAfterCompleted = false
      pathStep.options.preserveCompleted = true
    
    # Step index 0 is the first path.
    
    new @constructor.Steps.OpenEvaluationPaper @, stepArea, stepIndex: 1
    
    new @constructor.Steps.ClickOnEvenDiagonals @, stepArea, stepIndex: 2
    
    new @constructor.Steps.HoverOverTheDiagonal @, stepArea, stepIndex: 3
    
    new @constructor.Steps.AlternatingLine @, stepArea,
      svgPaths: pathSteps[0].options.svgPaths
      stepIndex: 4
      
    new @constructor.Steps.CloseEvaluationPaper @, stepArea, stepIndex: 5
    
    # Step index 6 is the second path.
    
    new @constructor.Steps.AlternatingLine @, stepArea,
      svgPaths: pathSteps[1].options.svgPaths
      stepIndex: 7
    
    new @constructor.Steps.CloseEvaluationPaper @, stepArea, stepIndex: 8

    # Step index 9 is the third path.
    
    new @constructor.Steps.AlternatingLine @, stepArea,
      svgPaths: pathSteps[2].options.svgPaths
      stepIndex: 10
      
    new @constructor.Steps.CloseEvaluationPaper @, stepArea, stepIndex: 11
    
    # Step index 12 is the final, fourth path.

    new @constructor.Steps.EnableEndSegments @, stepArea, stepIndex: 13
    
    new @constructor.Steps.FinalLine @, stepArea,
      svgPaths: pathSteps[3].options.svgPaths
