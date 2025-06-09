AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# A general instruction that is displayed after a delay if the asset is not completed at a specific active step.
class PAA.Tutorials.Drawing.Instructions.Multiarea.Instruction extends PAA.Tutorials.Drawing.Instructions.Instruction
  @referenceUrl: -> throw new AE.NotImplementedException "A multiarea instruction must specify to which reference it applies."
  
  constructor: ->
    super arguments...
    
    # Track the step area where the latest progress was made.
    @activeStepAreaIndex = new ReactiveField null
    
    @_lastActiveStepIndices = []
    
    @_updateActiveStepAreaAutorun = Tracker.autorun =>
      return unless asset = @getActiveAsset()
      
      activeStepIndices = (stepArea.activeStepIndex() for stepArea in asset.stepAreas())
      
      if activeStepIndices.length is 0
        @activeStepAreaIndex null
        
      else if activeStepIndices.length > @_lastActiveStepIndices.length
        @activeStepAreaIndex activeStepIndices.length - 1
        
      else if activeStepIndices.length < @_lastActiveStepIndices.length
        @activeStepAreaIndex null
        
      else
        for i in [0...activeStepIndices.length]
          if activeStepIndices[i] isnt @_lastActiveStepIndices[i]
            @activeStepAreaIndex i
            break
        
      @_lastActiveStepIndices = activeStepIndices
    
  destroy: ->
    super arguments...
    
    @_updateActiveStepAreaAutorun.stop()
    
  stepAreaActive: ->
    return unless asset = @getActiveAsset()
    activeStepAreaIndex = @activeStepAreaIndex()
    return unless activeStepAreaIndex?
    
    asset.stepAreas()[activeStepAreaIndex]?.data().referenceUrl is @constructor.referenceUrl()
