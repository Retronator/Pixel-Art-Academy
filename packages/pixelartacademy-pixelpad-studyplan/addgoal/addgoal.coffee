AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelPad.Apps.StudyPlan.AddGoal extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.AddGoal'
  @register @id()

  constructor: (@studyPlan) ->
    super arguments...

  onCreated: ->
    super arguments...
    
    @existingGoalIDs = new ComputedField =>
      return [] unless @studyPlan.ready()
      return [] unless goalsData = @studyPlan.state 'goals'
      _.keys goalsData

    @availableGoals = new ComputedField =>
      return unless interests = @studyPlan.addGoalOptions()?.availableInterests
      existingGoalIDs = @existingGoalIDs()

      _.filter @studyPlan.goals(), (goal) =>
        # Filter out all existing goals.
        return if goal.id() in existingGoalIDs
        
        # See if any of initial tasks has all their requirements met.
        for task in goal.initialTasks()
          requiredInterests = task.requiredInterests()
          return true if _.intersection(requiredInterests, interests).length is requiredInterests.length
          
        false

  events: ->
    super(arguments...).concat
      'click': @onClick
      'click .goal': @onClickGoal
  
  onClick: (event) ->
    return if $(event.target).closest('.window').length
    
    @studyPlan.closeAddGoal()
  
  onClickGoal: (event) ->
    goal = @currentData()
    
    @studyPlan.addGoal {goal}
