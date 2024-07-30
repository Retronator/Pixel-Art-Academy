AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  # Override to create a step for each path in the svg.
  @breakPathsIntoSteps: -> false
  
  # Override to set the default whether created steps draw hints after completion.
  @drawHintsAfterCompleted: -> null

  initializeSteps: ->
    fixedDimensions = @constructor.fixedDimensions()
    
    stepAreaBounds =
      x: 0
      y: 0
      width: fixedDimensions.width
      height: fixedDimensions.height
    
    if @resources.goalPixels or @resources.svgPaths or @resources.steps
      stepArea = new @constructor.StepArea @, stepAreaBounds
      @initializeStepsInAreaWithResources stepArea, @resources
      
  initializeStepsInAreaWithResources: (stepArea, stepResources) ->
    drawHintsAfterCompleted = @constructor.drawHintsAfterCompleted()
    
    if stepResources.goalPixels
      new @constructor.PixelsStep @, stepArea,
        startPixels: stepResources.startPixels
        goalPixels: stepResources.goalPixels
        drawHintsAfterCompleted: drawHintsAfterCompleted
        
    if stepResources.svgPaths
      svgPaths = stepResources.svgPaths.svgPaths()
      
      if @constructor.breakPathsIntoSteps()
        for svgPath, index in svgPaths
          new @constructor.PathStep @, stepArea,
            startPixels: if index is 0 then @resources.startPixels else null
            svgPaths: [svgPath]
            drawHintsAfterCompleted: drawHintsAfterCompleted
      
      else
        new @constructor.PathStep @, stepArea,
          startPixels: @resources.startPixels
          svgPaths: svgPaths
          drawHintsAfterCompleted: drawHintsAfterCompleted
    
    if stepResources.steps
      @initializeStepsInAreaWithResources stepArea, step for step in stepResources.steps
