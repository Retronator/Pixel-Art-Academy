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
    
    @availableGoals = new ComputedField =>
      return unless goalIDs = @studyPlan.addGoalOptions()?.goalIDs
      
      # Sideways goals can be sent as an array per index.
      goalIDs = _.flatten goalIDs

      _.filter @studyPlan.goals(), (goal) => goal.id() in goalIDs
      
    @shortTermGoals = new ComputedField =>
      currentInterests = LOI.adventure.currentInterests()
      
      _.filter @availableGoals(), (goal) =>
        # See if any of initial tasks has all their requirements met.
        for task in goal.initialTasks()
          requiredInterests = task.requiredInterests()
          return true if _.intersection(requiredInterests, currentInterests).length is requiredInterests.length
          
        false

    @midTermGoals = new ComputedField =>
      _.difference @availableGoals(), @shortTermGoals()

  showShortTermGoals: ->
    @shortTermGoals().length
    
  showMidTermGoals: ->
    @midTermGoals().length
    
  events: ->
    super(arguments...).concat
      'click': @onClick
      'click .goal': @onClickGoal
  
  onClick: (event) ->
    return if $(event.target).closest('.window').length
    
    @studyPlan.closeAddGoal()
  
  onClickGoal: (event) ->
    goal = @currentData()
    
    addGoalOptions = {goal}
    
    # If sideways goals are sent as an array per index, determine which index was chosen.
    sidewaysIndex = _.findIndex @studyPlan.addGoalOptions().goalIDs, (goalIDEntry) =>
      _.isArray(goalIDEntry) and goal.id() in goalIDEntry
    
    addGoalOptions.sidewaysIndex = sidewaysIndex if sidewaysIndex >= 0
    
    @studyPlan.addGoal addGoalOptions
