AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  initializeSteps: ->
    fixedDimensions = @constructor.fixedDimensions()
    
    stepAreaBounds =
      x: 0
      y: 0
      width: fixedDimensions.width
      height: fixedDimensions.height
    
    if @resources.goalPixels or @resources.svgPaths or @resources.steps
      stepArea = new @constructor.StepArea @, stepAreaBounds
      @_createSteps stepArea, @resources
      
  _createSteps: (stepArea, stepResource) ->
    if stepResource.goalPixels
      new @constructor.PixelsStep @, stepArea,
        startPixels: stepResource.startPixels
        goalPixels: stepResource.goalPixels
        
    if stepResource.svgPaths
      svgPaths = stepResource.svgPaths.svgPaths()
      
      if @constructor.breakPathsIntoSteps()
        for svgPath, index in svgPaths
          new @constructor.PathStep @, stepArea,
            startPixels: if index is 0 then @resources.startPixels else null
            svgPaths: [svgPath]
      
      else
        new @constructor.PathStep @, stepArea,
          startPixels: @resources.startPixels
          svgPaths: svgPaths
          
    if stepResource.steps
      @_createSteps stepArea, step for step in stepResource.steps
