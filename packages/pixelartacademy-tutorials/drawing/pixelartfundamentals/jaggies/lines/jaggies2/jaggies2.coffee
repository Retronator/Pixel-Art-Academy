LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Jaggies2 extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Jaggies2"

  @displayName: -> "Jaggies 2"
  
  @description: -> """
    Some jaggies are less desirable than others.
  """
  
  @fixedDimensions: -> width: 37, height: 22
  
  @resources: ->
    path = '/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/jaggies2'

    line1:
      goalPixels: new @Resource.ImagePixels "#{path}-1-goal.png"
    line2a:
      goalPixels: new @Resource.ImagePixels "#{path}-2.png"
    line2b:
      goalPixels: new @Resource.ImagePixels "#{path}-2-goal.png"
    line3a:
      goalPixels: new @Resource.ImagePixels "#{path}-3.png"
    line3b:
      goalPixels: new @Resource.ImagePixels "#{path}-3-goal.png"
    line4a:
      goalPixels: new @Resource.ImagePixels "#{path}-4.png"
    line4b:
      hintPixels: new @Resource.ImagePixels "#{path}-4-hints.png"
      goalPixels: new @Resource.ImagePixels "#{path}-4-goal.png"
    line5a:
      goalPixels: new @Resource.ImagePixels "#{path}-5.png"
    line5b:
      hintPixels: new @Resource.ImagePixels "#{path}-5-hints.png"
      goalPixels: new @Resource.ImagePixels "#{path}-5-goal.png"
    
  @markup: -> true
  @pixelArtEvaluation: -> partialUpdates: true
  
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
    
    # Line 1: Step 1 simply requires you to draw its goal pixels.
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line1.goalPixels
      
    # Line 2: You draw the line yourself in step 2 and then remove the doubles in step 3.
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line2a.goalPixels
      preserveCompleted: true
      hasPixelsWhenInactive: false
      drawHintsAfterCompleted: false
      
    new @constructor.Steps.LineWithoutDoublesStep @, stepArea,
      allowedPixels: @resources.line2a.goalPixels
      goalPixels: @resources.line2b.goalPixels

    # Line 3: You draw the line yourself in step 4 and then remove the doubles in step 5.
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line3a.goalPixels
      preserveCompleted: true
      hasPixelsWhenInactive: false
      drawHintsAfterCompleted: false
      
    new @constructor.Steps.LineWithoutDoublesStep @, stepArea,
      allowedPixels: @resources.line3a.goalPixels
      goalPixels: @resources.line3b.goalPixels

    # Line 4: You draw the line yourself in step 6 and then move the pixel in step 7.
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line4a.goalPixels
      preserveCompleted: true
      hasPixelsWhenInactive: false
      drawHintsAfterCompleted: false
    
    new @constructor.Steps.FixStep @, stepArea,
      hintPixels: @resources.line4b.hintPixels
      goalPixels: @resources.line4b.goalPixels

    # Line 5: You draw the line yourself in step 8 and then move the pixels in step 9.
    new @constructor.PixelsStep @, stepArea,
      goalPixels: @resources.line5a.goalPixels
      preserveCompleted: true
      hasPixelsWhenInactive: false
      drawHintsAfterCompleted: false
    
    new @constructor.Steps.FixStep @, stepArea,
      hintPixels: @resources.line5b.hintPixels
      goalPixels: @resources.line5b.goalPixels
