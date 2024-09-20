LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.StraightParts extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.StraightParts"
  
  @displayName: -> "Straight parts"
  
  @description: -> """
    When drawing long curves, some parts can become straighter than necessary.
  """
  
  @fixedDimensions: -> width: 40, height: 28
  
  @resources: ->
    path = '/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/straightparts'
    
    line1:
      pixels: new @Resource.ImagePixels "#{path}-1.png"
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
    pixelArtEvaluation:
      allowedCriteria: [PAE.Criteria.SmoothCurves]
      smoothCurves:
        ignoreMostlyStraightLines: false
        straightParts: {}
  
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
    
    # Step 1 requires you to draw the first path and open the smooth curves breakdown.
    new @constructor.Steps.DrawAndAnalyze @, stepArea,
      goalPixels: @resources.line1.pixels
      svgPaths: [svgPaths[0]]
      preserveCompleted: true
      hasPixelsWhenInactive: false
      canCompleteWithExtraPixels: false
    
    # Step 2 requires you to close the evaluation paper.
    new PAA.Tutorials.Drawing.PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Step 3 requires you to fix the line.
    new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.FixCurveStep @, stepArea,
      previousPixels: @resources.line1.pixels
      goalPixels: @resources.line1.goalPixels
      preserveCompleted: true
      hasPixelsWhenInactive: false
      canCompleteWithExtraPixels: false
    
    # Step 4 requires you to draw the second path.
    new @constructor.Steps.DrawAndAnalyze @, stepArea,
      goalPixels: @resources.line2.pixels
      svgPaths: [svgPaths[1]]
      preserveCompleted: true
      hasPixelsWhenInactive: false
      canCompleteWithExtraPixels: false
    
    # Step 5 requires you to fix the line.
    new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.FixCurveStep @, stepArea,
      previousPixels: @resources.line2.pixels
      goalPixels: @resources.line2.goalPixels
      preserveCompleted: true
      hasPixelsWhenInactive: false
      
    # Step 6 requires you to draw the third and fourth paths and open the smooth curves breakdown.
    new @constructor.Steps.DrawAndAnalyze @, stepArea,
      goalPixels: @resources.line3.pixels
      svgPaths: [svgPaths[2], svgPaths[3]]
      preserveCompleted: true
      hasPixelsWhenInactive: false
      canCompleteWithExtraPixels: false
      
    # Step 13 requires you to close the evaluation paper.
    new PAA.Tutorials.Drawing.PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Step 14 requires you to fix the line.
    new PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.FixCurveStep @, stepArea,
      previousPixels: @resources.line3.pixels
      goalPixels: @resources.line3.goalPixels
      hasPixelsWhenInactive: false
