AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.StepArea
  constructor: (@tutorialBitmap, @bounds) ->
    @stepAreaIndex = @tutorialBitmap.addStepArea @
    
    @steps = new ReactiveField []
    
    @data = new ComputedField =>
      @tutorialBitmap.data()?.stepAreas?[@stepAreaIndex]
    
    @activeStepIndex = new ComputedField =>
      @data()?.activeStepIndex
      
    @hasExtraPixels = new AE.LiveComputedField =>
      return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
      return unless palette = @tutorialBitmap.palette()
      backgroundColor = @tutorialBitmap.getBackgroundColor()
      
      # See if there are any pixels in our area that don't belong to any step.
      for x in [@bounds.x...@bounds.x + @bounds.width]
        for y in [@bounds.y...@bounds.y + @bounds.height]
          # Extra pixels can only exist where pixels are placed.
          continue unless pixel = bitmapLayer.getPixel x, y
          
          # Make sure the pixel doesn't match the background color.
          continue if @_isPixelEmpty pixel, backgroundColor, palette
          
          # If we don't find a step that requires this pixel, we have an extra.
          return true unless @hasGoalPixel x, y
          
      false
      
    @hasMissingPixels = new AE.LiveComputedField =>
      # Compare goal layer with current bitmap layer.
      return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
      return unless palette = @tutorialBitmap.palette()
  
      backgroundColor = @tutorialBitmap.getBackgroundColor()
  
      for x in [@bounds.x...@bounds.x + @bounds.width]
        for y in [@bounds.y...@bounds.y + @bounds.height]
          # Missing pixels can only exist where there is a goal pixel.
          continue unless @hasGoalPixel x, y
          
          # If we don't have a pixel at all, it's definitely a missing one.
          return true unless pixel = bitmapLayer.getPixel x, y
          
          # Make sure the pixel doesn't match the background color.
          return true if @_isPixelEmpty pixel, backgroundColor, palette
  
      false
      
    @completed = new ReactiveField false
    
    @_progressAutorun = Tracker.autorun (autorun) =>
      # Don't recompute when loading/unloading.
      return unless assets = @tutorialBitmap.tutorial.state 'assets'
      return unless asset = _.find assets, (asset) => asset.id is @tutorialBitmap.id()
      
      # Don't recompute when resetting.
      return if @tutorialBitmap.resetting()
      
      steps = @steps()
      return unless steps.length
      
      # Note, we do not want to read the active step index from the computed field since it will
      # need time to recalculate. We want to rely on the object we're also changing (the asset data).
      activeStepIndex = asset.stepAreas?[@stepAreaIndex]?.activeStepIndex
      
      completedSteps = 0
      
      for step, stepIndex in steps
        if (step.preserveCompleted() and stepIndex < activeStepIndex) or step.completed()
          completedSteps++
        
        else
          break
      
      # The asset is completed if all steps are completed and we have no extra pixels.
      @completed completedSteps is steps.length and not @hasExtraPixels()
      
      # See if we progressed (the active step index has changed).
      newActiveStepIndex = Math.min completedSteps, steps.length - 1
      return if activeStepIndex is newActiveStepIndex

      Tracker.nonreactive =>
        # Activate the step when progressing to it.
        if newActiveStepIndex > activeStepIndex or not activeStepIndex
          step = @steps()[newActiveStepIndex]
          # To preserve steps completed before migration to step areas, only activate steps that aren't completed.
          # We assume that a step would not be returning true for completed if it hasn't been activated yet.
          step.activate() unless step.completed()
        
        # Update the index in the asset.
        asset.stepAreas ?= []
        asset.stepAreas[@stepAreaIndex] ?= {}
        asset.stepAreas[@stepAreaIndex].activeStepIndex = newActiveStepIndex
        
        @tutorialBitmap.tutorial.state 'assets', assets

  destroy: ->
    @hasExtraPixels.stop()
    @hasMissingPixels.stop()
    @_progressAutorun.stop()
  
  _isPixelEmpty: (pixel, backgroundColor, palette) ->
    # We're empty if we don't have a pixel.
    return true unless pixel
    
    # We do have a pixel, so if there is no background color, it can't be empty.
    return false unless backgroundColor
    
    # We have a pixel and a background color, the pixel is empty if it matches it.
    if pixel.paletteColor
      pixelColor = palette.color pixel.paletteColor.ramp, pixel.paletteColor.shade
    
    else
      pixelColor = THREE.Color.fromObject pixel.directColor
    
    pixelColor.equals backgroundColor
    
  addStep: (step, stepIndex) ->
    steps = @steps()
    
    if stepIndex
      steps.splice stepIndex, 0, step
      
    else
      steps.push step
      
    @steps steps
  
  solve: ->
    step.solve() for step in @steps()
    
  reset: ->
    step.reset() for step in @steps()
  
  hasGoalPixel: (absoluteX, absoluteY) ->
    # Check if any of the steps require a pixel at these absolute bitmap coordinates.
    for step in @steps()
      return true if step.hasPixel absoluteX, absoluteY
    
    false
