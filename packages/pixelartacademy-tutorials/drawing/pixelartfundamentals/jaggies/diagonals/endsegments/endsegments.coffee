LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

PixelArtFundamentals = PAA.Tutorials.Drawing.PixelArtFundamentals

class PixelArtFundamentals.Jaggies.Diagonals.EndSegments extends PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.EndSegments"

  @displayName: -> "Matching end segments"
  
  @description: -> """
    With longer lines, another consideration is the length of end segments.
  """
  
  @fixedDimensions: -> width: 63, height: 19
  
  @resources: ->
    path = '/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/diagonals/endsegments'
    
    line1:
      endPixels: new @Resource.ImagePixels "#{path}-1.png"
      bresenhamPixels: new @Resource.ImagePixels "#{path}-2.png"
      alternatingPixels: new @Resource.ImagePixels "#{path}-3.png"
    line2:
      endPixels: new @Resource.ImagePixels "#{path}-4.png"
      bresenhamPixels: new @Resource.ImagePixels "#{path}-5.png"
      extensionPixels: new @Resource.ImagePixels "#{path}-6.png"
  
  @markup: -> true
  @pixelArtEvaluation: -> true
  
  @properties: ->
    pixelArtScaling: true
    pixelArtEvaluation:
      allowedCriteria: [PAE.Criteria.EvenDiagonals]
      evenDiagonals:
        segmentLengths: {}
        endSegments: {}
      
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
    
    # Steps 1 and 2 require you to draw a Bresenham line between the dots.
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line1.endPixels
      canCompleteWithExtraPixels: true
    
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line1.bresenhamPixels
      preserveCompleted: true
      hasPixelsWhenInactive: false
    
    # Step 3 requires you to open the even diagonals breakdown.
    new PixelArtFundamentals.OpenEvaluationCriterion @, stepArea,
      criterion: PAE.Criteria.EvenDiagonals
  
    # Step 4 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Step 5 requires you to fix the line
    new PixelArtFundamentals.Jaggies.FixLineStep @, stepArea,
      previousPixels: @resources.line1.bresenhamPixels
      goalPixels: @resources.line1.alternatingPixels
    
    # Step 6 requires you to close the evaluation paper.
    new PixelArtFundamentals.CloseEvaluationPaper @, stepArea

    # Steps 7 and 8 require you to draw a Bresenham line between the dots.
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line2.endPixels
      canCompleteWithExtraPixels: true
    
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line2.bresenhamPixels
      preserveCompleted: true
      
    # Step 9 requires you to extend the line
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line2.extensionPixels
