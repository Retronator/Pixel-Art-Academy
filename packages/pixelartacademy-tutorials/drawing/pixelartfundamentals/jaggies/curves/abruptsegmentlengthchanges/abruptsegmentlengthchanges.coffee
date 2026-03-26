LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PixelArtFundamentals = PAA.Tutorials.Drawing.PixelArtFundamentals

class PixelArtFundamentals.Jaggies.Curves.AbruptSegmentLengthChanges extends PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.AbruptSegmentLengthChanges"
  
  @displayName: -> "Abrupt segment length changes"
  
  @description: -> """
    Use pixel art evaluation to analyze when the lengths of curve segments change too quickly.
  """
  
  @fixedDimensions: -> width: 30, height: 25
  
  @resources: ->
    path = '/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/abruptsegmentlengthchanges'
    
    line1:
      goalPixels: new @Resource.ImagePixels "#{path}-1-goal.png"
    line2:
      pixels: new @Resource.ImagePixels "#{path}-2.png"
      goalPixels: new @Resource.ImagePixels "#{path}-2-goal.png"
    line3:
      pixels: new @Resource.ImagePixels "#{path}-3.png"
      goalPixels: new @Resource.ImagePixels "#{path}-3-goal.png"
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
    
    # Line 1: Step 1 requires you to draw the goal pixels based on the first path.
    new @constructor.Steps.DrawLine @, stepArea,
      goalPixels: @resources.line1.goalPixels
      svgPaths: [svgPaths[2]]
      preserveCompleted: true
      hasPixelsWhenInactive: false
    
    # Step 2 requires you to open the evaluation paper.
    new @constructor.Steps.OpenEvaluationPaper @, stepArea
    
    # Step 3 requires you to hover over the curve.
    new @constructor.Steps.HoverOverTheCurve @, stepArea
    
    # Step 4 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea

    # Line 2: Step 5 requires you to draw the second path.
    new @constructor.PixelsWithPathsStep @, stepArea,
      goalPixels: @resources.line2.pixels
      svgPaths: [svgPaths[1]]
      preserveCompleted: true
      hasPixelsWhenInactive: false
    
    # Step 6 requires you to open the evaluation paper.
    new PixelArtFundamentals.OpenEvaluationPaper @, stepArea
    
    # Step 7 requires you to open the smooth curves breakdown.
    new PixelArtFundamentals.OpenEvaluationCriterion @, stepArea,
      criterion: PAE.Criteria.SmoothCurves
    
    # Step 8 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Step 9 requires you to fix the line.
    new PixelArtFundamentals.Jaggies.FixLineStep @, stepArea,
      previousPixels: @resources.line2.pixels
      goalPixels: @resources.line2.goalPixels
      preserveCompleted: true
      hasPixelsWhenInactive: false
      
    # Line 3: Step 10 requires you to draw the third path.
    new @constructor.PixelsWithPathsStep @, stepArea,
      goalPixels: @resources.line3.pixels
      svgPaths: [svgPaths[0]]
      preserveCompleted: true
      hasPixelsWhenInactive: false
      
    # Step 11 requires you to open the evaluation paper.
    new PixelArtFundamentals.OpenEvaluationPaper @, stepArea
    
    # Step 12 requires you to open the smooth curves breakdown.
    new PixelArtFundamentals.OpenEvaluationCriterion @, stepArea,
      criterion: PAE.Criteria.SmoothCurves
    
    # Step 13 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Step 14 requires you to fix the line.
    new PixelArtFundamentals.Jaggies.FixLineStep @, stepArea,
      previousPixels: @resources.line3.pixels
      goalPixels: @resources.line3.goalPixels
      hasPixelsWhenInactive: false
