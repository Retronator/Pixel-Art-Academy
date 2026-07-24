AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.StepArea
  constructor: (@tutorialBitmap, @bounds) ->
    @stepAreaIndex = @tutorialBitmap.addStepArea @
    
    # Steps are created locally and provided to reactive consumers when all are created.
    @_steps = []
    @steps = new ReactiveField []
    
    @data = new AE.LiveComputedField =>
      # Don't recompute when loading/unloading.
      return unless assetData = @tutorialBitmap.data()
      
      # Tutorial bitmap data is valid so if there is no step area data, it defaults to empty.
      assetData.stepAreas?[@stepAreaIndex] or {}
    ,
      EJSON.equals
    
    @activeStepIndex = new ReactiveField @data()?.activeStepIndex
    @activeStep = new ReactiveField null
    
    @hasExtraPixels = new ReactiveField null
    @hasMissingPixels = new ReactiveField null
    @completed = new ReactiveField null

  destroy: ->
    @_progressAutorun?.stop()
    step.destroy() for step in @steps()
    
  addStep: (step, stepIndex) ->
    if stepIndex?
      @_steps.splice stepIndex, 0, step
      
    else
      @_steps.push step
  
  getStepIndex: (step) ->
    @_steps.indexOf step
    
  initialize: ->
    @steps @_steps
    
    @_progressAutorun = Tracker.nonreactive => Tracker.autorun (autorun) =>
      return unless stepAreaData = @data()
      
      # Check if we have newer data because we just updated it.
      # Note: This lets us minimize reactivity by relying on recomputation
      # of data, but also have live data if we were the one to update it.
      if @_latestData
        if EJSON.equals @_latestData, stepAreaData
          # Data has caught up, no need for substitution anymore.
          delete @_latestData
          
        else
          # We have newer data, use it.
          stepAreaData = @_latestData
      
      # Don't recompute when resetting.
      return if @tutorialBitmap.resetting()
      
      # Don't recompute until steps have been created.
      steps = @steps()
      return unless steps.length
      
      # Initialize active step and completed from stored state.
      activeStepIndex = stepAreaData.activeStepIndex
      @activeStepIndex activeStepIndex or 0
      @activeStep steps[activeStepIndex or 0]
      
      completed = stepAreaData.completed
      @completed completed or false
      
      # Activate the first step if we're starting fresh.
      @_activateStep steps[0] unless activeStepIndex?

      # Delay recomputation until drawing is active.
      return unless @tutorialBitmap.isActiveDrawingInEditor()
      
      # Update information about extra and missing pixels for this active step.
      @_updateExtraAndMissingPixelsFields()
      
      # Update current active step.
      newActiveStepIndex = 0
      completedSteps = 0
      
      # For this step to be completed, this one and all previous steps have to be completed.
      for step, stepIndex in steps
        if (step.preserveCompleted() and (stepIndex < activeStepIndex or completed)) or step.completed()
          completedSteps++
          newActiveStepIndex = Math.min completedSteps, steps.length - 1

          # See if progress has happened.
          if newActiveStepIndex > activeStepIndex or not activeStepIndex
            # Update the fields that steps rely on for calculating their completed state.
            @activeStepIndex newActiveStepIndex
            
            newActiveStep = @steps()[newActiveStepIndex]
            @activeStep newActiveStep
            
            @_updateExtraAndMissingPixelsFields()
            
            # Activate the step.
            @_activateStep newActiveStep
        
        else
          break
      
      # The asset is completed if all steps are completed and we have no extra pixels.
      newCompleted = completedSteps is steps.length and not @hasExtraPixels()
      @completed newCompleted
      
      # See if we progressed (the active step index or completed has changed).
      return if newActiveStepIndex is activeStepIndex and newCompleted is completed
      
      # Update the index in the asset.
      # Note: We have to do this even on first run instead of relying on defaults, because
      # the presence of the activeStepIndex also tells us that this step has been activated.
      @_updateData newActiveStepIndex, newCompleted
      
  _updateData: (activeStepIndex, completed) ->
    assetData = Tracker.nonreactive => @tutorialBitmap.data()
    assetData.stepAreas ?= []
    existingAssetData = assetData.stepAreas[@stepAreaIndex]
    
    @_latestData = if existingAssetData then _.clone existingAssetData else {}
    @_latestData.activeStepIndex = activeStepIndex
    @_latestData.completed = completed
    
    assetData.stepAreas[@stepAreaIndex] = @_latestData
    @tutorialBitmap.setAssetData assetData
  
  solve: ->
    steps = @steps()

    for step in steps
      @_activateStep step
      step.solve()
    
    @_updateData steps.length, true
    
  reset: ->
    step.reset() for step in @steps()
    
  getInformation: ->
    return unless data = @data()
    
    if referenceUrl = data.referenceUrl
      goalChoice = _.find @tutorialBitmap.resources.goalChoices, (goalChoice) => goalChoice.referenceUrl is referenceUrl
      goalChoice.information
      
    else
      @tutorialBitmap.resources.information
  
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
