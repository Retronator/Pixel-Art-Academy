LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.LineArtCleanup extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.LineArtCleanup"
  
  @displayName: -> "Line art cleanup"
  
  @description: -> """
    Practice cleaning up doubles and corners.
  """
  
  @fixedDimensions: -> width: 40, height: 30
  
  @resources: ->
    requiredPath: new @Resource.SvgPaths "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/lineartcleanup.svg"
  
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
    
    # Step 1 requires you to connect all the required pixels.
    svgPaths = @resources.requiredPath.svgPaths()
    new @constructor.Steps.DrawLine @, stepArea, {svgPaths}
    
    # Step 2 requires you to open the evaluation paper.
    new @constructor.Steps.OpenEvaluationPaper @, stepArea
    
    # Step 3 requires you to open the pixel-perfect lines details page.
    new @constructor.Steps.OpenPixelPerfectLines @, stepArea
    
    # Step 4 requires you to hover over doubles or corners.
    new @constructor.Steps.HoverOverCriterion @, stepArea
    
    # Step 5 requires you to close the evaluation paper.
    new PAA.Tutorials.Drawing.PixelArtFundamentals.CloseEvaluationPaper @, stepArea
    
    # Step 6 requires you to clean up the line of all doubles.
    new @constructor.Steps.CleanLine @, stepArea, {svgPaths}
