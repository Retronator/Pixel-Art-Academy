import {ReactiveField} from "meteor/peerlibrary:reactive-field"

AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.StepArea
  constructor: (@tutorialBitmap, @bounds) ->
    @stepAreaIndex = @tutorialBitmap.addStepArea @
    
    @steps = new ReactiveField []
    
    @data = new ReactiveField @tutorialBitmap.getAssetData()?.stepAreas?[@stepAreaIndex]
    @activeStepIndex = new ReactiveField @data()?.activeStepIndex
    @activeStep = new ReactiveField null
    
    @hasExtraPixels = new ReactiveField null
    @hasMissingPixels = new ReactiveField null
    @completed = new ReactiveField false
    
    @_progressAutorun = Tracker.autorun (autorun) =>
      # Don't recompute when loading/unloading.
      return unless assetData = @tutorialBitmap.getAssetData()
      
      # Update current data.
      stepAreaData = assetData.stepAreas?[@stepAreaIndex]
      @data stepAreaData
      
      # Don't recompute when resetting.
      return if @tutorialBitmap.resetting()
      
      # Don't recompute until steps have been created.
      steps = @steps()
      return unless steps.length
      
      # Initialize active step from stored state.
      activeStepIndex = stepAreaData?.activeStepIndex
      @activeStepIndex activeStepIndex or 0
      @activeStep steps[activeStepIndex or 0]
      
      # Activate the first step if we're starting fresh.
      @_activateStep steps[0] unless activeStepIndex?
      
      # Update information about extra and missing pixels for this active step.
      @_updateExtraAndMissingPixelsFields()
      
      # Update current active step.
      completedSteps = 0
      
      # For this step to be completed, this one and all previous steps have to be completed.
      for step, stepIndex in steps
        if (step.preserveCompleted() and stepIndex < activeStepIndex) or step.completed()
          completedSteps++
          newActiveStepIndex = Math.min completedSteps, steps.length - 1

          # See if progress has happened.
          if newActiveStepIndex > activeStepIndex or not activeStepIndex
            # Update the fields that steps rely on for calculating their completed state.
            @activeStepIndex newActiveStepIndex
            
            newActiveStep =  @steps()[newActiveStepIndex]
            @activeStep newActiveStep
            
            @_updateExtraAndMissingPixelsFields()
            
            # Activate the step.
            @_activateStep newActiveStep
        
        else
          break
      
      # The asset is completed if all steps are completed and we have no extra pixels.
      @completed completedSteps is steps.length and not @hasExtraPixels()
      
      # See if we progressed (the active step index has changed).
      newActiveStepIndex = Math.min completedSteps, steps.length - 1
      return if activeStepIndex is newActiveStepIndex
      
      # Update the index in the asset.
      assetData.stepAreas ?= []
      assetData.stepAreas[@stepAreaIndex] ?= {}
      assetData.stepAreas[@stepAreaIndex].activeStepIndex = newActiveStepIndex
      
      @tutorialBitmap.setAssetData assetData

  destroy: ->
    @_progressAutorun.stop()
    step.destroy() for step in @steps()
    
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
    
  _updateExtraAndMissingPixelsFields: ->
    return unless bitmapLayer = @tutorialBitmap.bitmap()?.layers[0]
    return unless palette = @tutorialBitmap.palette()
    backgroundColor = @tutorialBitmap.backgroundColor()
    
    hasExtraPixels = false
    hasMissingPixels = false
    
    for x in [@bounds.x...@bounds.x + @bounds.width]
      for y in [@bounds.y...@bounds.y + @bounds.height]
        pixel = bitmapLayer.getPixel x, y
        hasGoalPixel = @hasGoalPixel x, y
        isPixelEmpty = TutorialBitmap._isPixelEmpty pixel, backgroundColor, palette
        
        # If still needed, see if there are any pixels in our area that don't belong to any step.
        unless hasExtraPixels
          # Extra pixels can only exist where pixels are placed.
          if pixel
            # Make sure the pixel doesn't match the background color.
            unless isPixelEmpty
              # If we don't find a step that requires this pixel, we have an extra.
              hasExtraPixels = true unless hasGoalPixel
          
        # If still needed, see if there are any pixels missing in our area that still need to be covered.
        unless hasMissingPixels
          # Missing pixels can only exist where there is a goal pixel.
          if hasGoalPixel
            # If we don't have a pixel at all, it's definitely a missing one.
            unless pixel
              hasMissingPixels = true

            # Make sure the pixel doesn't match the background color.
            else if isPixelEmpty
              hasMissingPixels = true
          
        # If both test have passed, no need to keep going.
        if hasExtraPixels and hasMissingPixels
          @hasExtraPixels true
          @hasMissingPixels true
          return
          
    @hasExtraPixels hasExtraPixels
    @hasMissingPixels hasMissingPixels
    
  _activateStep: (step) ->
    # Activate the step. To preserve steps completed before migration to step areas, only activate steps that
    # aren't completed. We assume that a step would not be returning true for completed if it hasn't been
    # activated yet.
    Tracker.nonreactive => step.activate() unless step.completed()
