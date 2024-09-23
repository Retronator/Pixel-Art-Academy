LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PixelArtFundamentals = PAA.Tutorials.Drawing.PixelArtFundamentals

class PixelArtFundamentals.Jaggies.Curves.InflectionPoints extends PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.InflectionPoints"
  
  @displayName: -> "Inflection points"
  
  @description: -> """
    Analyze points where curves change direction.
  """
  
  @fixedDimensions: -> width: 42, height: 30
  
  @resources: ->
    path = '/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/inflectionpoints'
    
    start: new @Resource.ImagePixels "#{path}-1.png"
    pixelPerfect: new @Resource.ImagePixels "#{path}-2.png"
    smooth: new @Resource.ImagePixels "#{path}-3.png"
    
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @properties: ->
    pixelArtScaling: true
    pixelArtEvaluation:
      allowedCriteria: [PAE.Criteria.SmoothCurves]
      smoothCurves:
        inflectionPoints: {}
  
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
    
    # Step 1 requires you to clean the doubles.
    new @constructor.PixelsStep @, stepArea,
      startPixels: @resources.start
      goalPixels: @resources.pixelPerfect
      preserveCompleted: true
      hasPixelsWhenInactive: false
      
    # Step 2 requires you to open the smooth curves breakdown.
    new PixelArtFundamentals.OpenEvaluationCriterion @, stepArea,
      criterion: PAE.Criteria.SmoothCurves
      
    # Step 3 requires you to clean the doubles and open the Smooth curves breakdown.
    new @constructor.Steps.AnalyzeInflectionPoints @, stepArea
    
    # Step 4 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Step 5 requires you to fix the line.
    new PixelArtFundamentals.Jaggies.Curves.FixCurveStep @, stepArea,
      previousPixels: @resources.pixelPerfect
      goalPixels: @resources.smooth
      hasPixelsWhenInactive: false
