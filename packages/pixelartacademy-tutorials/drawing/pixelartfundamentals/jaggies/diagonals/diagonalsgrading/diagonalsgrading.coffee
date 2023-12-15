LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
Markup = PAA.Practice.Helpers.Drawing.Markup
PAG = PAA.Practice.PixelArtGrading
StraightLine = PAG.Line.Part.StraightLine

# Note: We can't call this Instructions since we introduce a namespace class called that below.
InstructionsSystem = PAA.PixelPad.Systems.Instructions

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.DiagonalsGrading extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.DiagonalsGrading"

  @displayName: -> "Diagonals grading"
  
  @description: -> """
    Learn how the pixel art grading sheet can help you identify types of diagonals.
  """
  
  @fixedDimensions: -> width: 30, height: 29
  
  @svgUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/diagonalsgrading.svg"
  @breakPathsIntoSteps: -> true
  @drawHintsAfterCompleted: -> false
  
  @markup: -> true
  @pixelArtGrading: -> true

  @properties: ->
    pixelArtScaling: true
    pixelArtGrading:
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
    
    new @constructor.Steps.OpenGradingSheet @, stepArea, stepIndex: 1
    
    new @constructor.Steps.ClickOnEvenDiagonals @, stepArea, stepIndex: 2
    
    new @constructor.Steps.HoverOverTheDiagonal @, stepArea, stepIndex: 3
    
    new @constructor.Steps.AlternatingLine @, stepArea,
      svgPaths: pathSteps[0].options.svgPaths
      stepIndex: 4
      
    new @constructor.Steps.CloseGradingSheet @, stepArea, stepIndex: 5
    
    # Step index 6 is the second path.
    
    new @constructor.Steps.CloseGradingSheet @, stepArea, stepIndex: 7
    
    new @constructor.Steps.AlternatingLine @, stepArea,
      svgPaths: pathSteps[1].options.svgPaths
      stepIndex: 8
    
    new @constructor.Steps.CloseGradingSheet @, stepArea, stepIndex: 9

    # Step index 10 is the third path.
    
    new @constructor.Steps.AlternatingLine @, stepArea,
      svgPaths: pathSteps[2].options.svgPaths
      stepIndex: 11
      
    new @constructor.Steps.CloseGradingSheet @, stepArea, stepIndex: 12
    
    # Step index 13 is the final, fourth path.

    new @constructor.Steps.EnableEndSegments @, stepArea, stepIndex: 14
    
    new @constructor.Steps.FinalLine @, stepArea,
      svgPaths: pathSteps[3].options.svgPaths
