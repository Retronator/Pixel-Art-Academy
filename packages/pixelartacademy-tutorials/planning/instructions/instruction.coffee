AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Planning.Instructions.Instruction extends PAA.PixelPad.Systems.Instructions.Instruction
  # The default amount of time before we show instructions to the user to let them figure it out themselves.
  @defaultDelayDuration = 5
  
  @getStudyPlan: ->
    PAA.PixelPad.Apps.StudyPlan.getApp()
  
  @getBlueprint: ->
    return unless blueprint = @getStudyPlan()?.blueprint()
    return unless blueprint.isCreated()
    blueprint
  
  @getGoalComponent: (goalOrGoalId) ->
    goalId = _.thingId goalOrGoalId
    
    return unless blueprint = @getBlueprint()
    return unless goalComponentsById = blueprint.goalComponentsById()
    return unless goalComponent = goalComponentsById[goalId]
    return unless goalComponent.isCreated()
    goalComponent
  
  getStudyPlan: -> @constructor.getStudyPlan()
  getBlueprint: -> @constructor.getBlueprint()
  getGoalComponent: -> @constructor.getGoalComponent arguments...
