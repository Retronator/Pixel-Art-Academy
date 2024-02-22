AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# A general instruction that is displayed after a delay if the asset is not completed.
class PAA.Tutorials.Drawing.Instructions.StepInstruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @stepNumber: ->
    # Override if the instruction should appear in a single step.
    null
    
  @stepNumbers: ->
    # Override if the instruction should appear in multiple steps.
    [@stepNumber()]
    
  @activeStepNumber: ->
    return unless asset = @getActiveAsset()
    asset.stepAreas()[0].activeStepIndex() + 1
  
  @activeConditions: ->
    return unless asset = @getActiveAsset()
    
    # Show with the correct step.
    return unless @activeStepNumber() in @stepNumbers()
    
    # Show until the asset is completed.
    not asset.completed()
  
  @resetDelayOnOperationExecuted: -> true
  
  getTutorialStep: (stepNumber) ->
    return unless asset = @getActiveAsset()
    
    stepNumber ?= @constructor.stepNumber()
    
    asset.stepAreas()[0].steps()[stepNumber - 1]
