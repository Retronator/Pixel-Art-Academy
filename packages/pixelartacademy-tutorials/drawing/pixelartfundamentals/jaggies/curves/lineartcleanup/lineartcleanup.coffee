LOI = LandsOfIllusions
PAA = PixelArtAcademy
PAE = PAA.Practice.PixelArtEvaluation

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LineArtCleanup extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.LineArtCleanup"
  
  @displayName: -> "Line art cleanup"
  
  @description: -> """
    Practice smoothing your curves.
  """
  
  @fixedDimensions: -> width: 40, height: 30
  
  @resources: ->
    requiredPixels: new @Resource.ImagePixels "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/curves/lineartcleanup.png"
  
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
    
    # Step 1 requires you to connect all the required pixels and open the evaluation paper.
    new @constructor.Steps.DrawLine @, stepArea,
      goalPixels: @resources.requiredPixels
    
    # Step 2 requires you to open the evaluation paper.
    new @constructor.Steps.OpenEvaluationPaper @, stepArea
    
    # Step 3 requires you to open the smooth curves details page.
    new @constructor.Steps.OpenSmoothCurves @, stepArea
    
    # Step 4 requires you to analyze the curve.
    new @constructor.Steps.AnalyzeTheCurve @, stepArea
    
    # Step 5 requires you to smoothen the curve.
    new @constructor.Steps.SmoothenTheCurve @, stepArea,
      goalPixels: @resources.requiredPixels
