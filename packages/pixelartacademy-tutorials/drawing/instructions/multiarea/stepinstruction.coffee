AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# A general instruction that is displayed after a delay if the asset is not completed at a specific active step.
class PAA.Tutorials.Drawing.Instructions.Multiarea.StepInstruction extends PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction
  @stepNumber: ->
    # Override if the instruction should appear in a single step.
    null
    
  @stepNumbers: ->
    # Override if the instruction should appear in multiple steps.
    [@stepNumber()]
  
  @resetDelayOnOperationExecuted: -> @delayDuration()
  
  activeStepNumber: ->
    return unless asset = @getActiveAsset()
    activeStepAreaIndex = @activeStepAreaIndex()
    return unless activeStepAreaIndex?
    
    asset.stepAreas()[activeStepAreaIndex].activeStepIndex() + 1
  
  activeConditions: ->
    return unless asset = @getActiveAsset()
    
    return unless @stepAreaActive()
    
    # Show with the correct step.
    return unless @activeStepNumber() in @constructor.stepNumbers()
    
    # Show until the asset is completed.
    not asset.completed()
    
  getTutorialStep: (stepNumber) ->
    return unless asset = @getActiveAsset()
    activeStepAreaIndex = @activeStepAreaIndex()
    return unless activeStepAreaIndex?
    
    stepNumber ?= @constructor.stepNumber()
    
    asset.stepAreas()[activeStepAreaIndex]?.steps()[stepNumber - 1]
