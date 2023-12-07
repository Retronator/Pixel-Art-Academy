AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.StepArea
  constructor: (@tutorialBitmap, @bounds) ->
    @stepAreaIndex = @tutorialBitmap.addStepArea @
    
    @steps = new ReactiveField []
    
    @data = new ComputedField =>
      @tutorialBitmap.data().stepAreas?[@stepAreaIndex]
    
    @activeStepIndex = new ComputedField =>
      @data()?.activeStepIndex
  
    @completed = new AE.LiveComputedField =>
      steps = @steps()
      return unless steps.length
      
      completedSteps = 0
      
      for step in steps
        if step.completed()
          completedSteps++
        
        else
          break
      
      # As a side effect, update which one is the current step to draw.
      Tracker.nonreactive => @_updateActiveStepIndex Math.min completedSteps, steps.length - 1
      
      # Note: We shouldn't quit early because of extra pixels, since we wouldn't update
      # active step index otherwise, so we do it here at the end as a final condition.
      completedSteps is steps.length and not @hasExtraPixels()

  destroy: ->
    @completed.stop()
    
  addStep: (step) ->
    steps = @steps()
    steps.push step
    @steps steps
  
  solve: ->
    step.solve() for step in @steps()
    
  hasExtraPixels: ->
    return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    
    # See if there are any pixels in our area that don't belong to any step.
    for x in [@bounds.x...@bounds.x + @bounds.width]
      for y in [@bounds.y...@bounds.y + @bounds.height]
        # Extra pixels can only exist where pixels are placed.
        continue unless bitmapLayer.getPixel x, y
        
        # If we don't find a step that requires this pixel, we have an extra.
        return true unless @hasGoalPixel x, y
        
    false
    
  hasMissingPixels: ->
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
        if backgroundColor
          pixelColor = pixel.directColor or palette.color pixel.paletteColor.ramp, pixel.paletteColor.shade
          return true if pixelColor.equals backgroundColor

    false
  
  hasGoalPixel: (x, y) ->
    # Check if any of the steps require a pixel at these absolute bitmap coordinates.
    for step in @steps()
      return true if step.hasPixel x, y
    
    false
    
  _updateActiveStepIndex: (index) ->
    # Note, we do not want to read the active step index from the computed field since it will
    # need time to recalculate. We want to rely on the object we're also changing (the asset data).
    assets = @tutorialBitmap.tutorial.assetsData()
    asset = _.find assets, (asset) => asset.id is @tutorialBitmap.id()

    activeStepIndex = asset.stepAreas?[@stepAreaIndex]?.activeStepIndex
    return if activeStepIndex is index
    
    # Activate the step when progressing to it.
    if index > activeStepIndex or not activeStepIndex
      @steps()[index].activate()
    
    # Update the index in the asset.
    asset.stepAreas ?= []
    asset.stepAreas[@stepAreaIndex] ?= {}
    asset.stepAreas[@stepAreaIndex].activeStepIndex = index
    
    @tutorialBitmap.tutorial.state 'assets', assets
