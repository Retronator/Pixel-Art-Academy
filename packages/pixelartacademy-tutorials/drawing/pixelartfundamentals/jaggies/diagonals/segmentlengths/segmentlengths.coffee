LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
Markup = PAA.Practice.Helpers.Drawing.Markup
PAE = PAA.Practice.PixelArtEvaluation
StraightLine = PAE.Line.Part.StraightLine
PixelArtFundamentals = PAA.Tutorials.Drawing.PixelArtFundamentals

class PixelArtFundamentals.Jaggies.Diagonals.SegmentLengths extends PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.SegmentLengths"

  @displayName: -> "Alternating and broken segment lengths"
  
  @description: -> """
    Learn how the pixel art evaluation paper can help you identify types of diagonals.
  """
  
  @fixedDimensions: -> width: 31, height: 53
  
  @resources: ->
    path = '/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/segmentlengths'
    
    firstLinesPixels: new @Resource.ImagePixels "#{path}.png"
    paths: new @Resource.SvgPaths "#{path}.svg"
  
  @markup: -> true
  @pixelArtEvaluation: -> true

  @properties: ->
    pixelArtScaling: true
  
  @initialize()
  
  initializeSteps: ->
    super arguments...
    
    fixedDimensions = @constructor.fixedDimensions()
    
    stepAreaBounds =
      x: 0
      y: 0
      width: fixedDimensions.width
      height: fixedDimensions.height
    
    stepArea = new @constructor.StepArea @, stepAreaBounds
    
    svgPaths = @resources.paths.svgPaths()
    
    # First lines: Step 1 requires you to draw the goal pixels based on the first 3 paths.
    new @constructor.Steps.DrawLine @, stepArea,
      goalPixels: @resources.firstLinesPixels
      svgPaths: [svgPaths[0], svgPaths[1], svgPaths[2]]
      preserveCompleted: true
    
    # Step 2 requires you to open the evaluation paper.
    new @constructor.Steps.OpenEvaluationPaper @, stepArea
    
    # Step 3 requires you to open the even diagonals breakdown.
    new PixelArtFundamentals.OpenEvaluationCriterion @, stepArea,
      criterion: PAE.Criteria.EvenDiagonals
      
    # Step 4 requires you to hover over the 3 diagonals.
    new @constructor.Steps.HoverOverTheDiagonals @, stepArea
    
    # Step 5 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Line 2:5: Step 6 requires you to draw the next line.
    new @constructor.PathStep @, stepArea,
      svgPaths: [svgPaths[3]]
      preserveCompleted: true

    # Step 7 requires to fix the line to be alternating.
    new @constructor.Steps.AlternatingLine @, stepArea,
      svgPaths: [svgPaths[3]]
    
    # Step 8 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Line 2:9: Step 9 requires you to draw the next line.
    new @constructor.PathStep @, stepArea,
      svgPaths: [svgPaths[4]]
      preserveCompleted: true
      
    # Step 10 requires this to be an alternating line.
    new @constructor.Steps.AlternatingLine @, stepArea,
      svgPaths: [svgPaths[4]]
    
    # Step 11 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Line 1:5: Step 12 requires you to draw the next line.
    new @constructor.PathStep @, stepArea,
      svgPaths: [svgPaths[5]]
      preserveCompleted: true
      
    # Step 13 requires this to be an even line.
    new @constructor.Steps.EvenLine @, stepArea,
      svgPaths: [svgPaths[5]]

    # Step 14 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea
