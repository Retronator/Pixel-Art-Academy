AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.AddGoal extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.AddGoal'
  @register @id()

  constructor: (@studyPlan) ->
    super arguments...

  onCreated: ->
    super arguments...
    
    @availableGoals = new ComputedField =>
      return unless goalIds = @studyPlan.addGoalOptions()?.goalIds
      
      # Sideways goals can be sent as an array per index.
      goalIds = _.flatten goalIds

      _.filter @studyPlan.goals(), (goal) => goal.id() in goalIds
    
    @accomplishedGoals = new ComputedField =>
      _.filter @availableGoals(), (goal) => goal.allCompleted()
      
    @unacomplishedGoals = new ComputedField =>
      _.difference @availableGoals(), @accomplishedGoals()
      
    @shortTermGoals = new ComputedField =>
      _.filter @unacomplishedGoals(), (goal) => StudyPlan.getGoalType(goal) is StudyPlan.GoalTypes.ShortTerm

    @midTermGoals = new ComputedField =>
      _.difference @unacomplishedGoals(), @shortTermGoals()

  sourceGoalIsMidTerm: ->
    return unless sourceGoalId = @studyPlan.addGoalOptions()?.sourceGoalId
    StudyPlan.getGoalType(sourceGoalId) is StudyPlan.GoalTypes.MidTerm
  
  showAccomplishedGoals: ->
    @accomplishedGoals().length
    
  showShortTermGoals: ->
    @shortTermGoals().length
    
  showMidTermGoals: ->
    @midTermGoals().length
    
  events: ->
    super(arguments...).concat
      'click .goal': @onClickGoal
  
  onClickGoal: (event) ->
    goal = @currentData()
    
    addGoalOptions = {goal}
    
    # If sideways goals are sent as an array per index, determine which index was chosen.
    sidewaysIndex = _.findIndex @studyPlan.addGoalOptions().goalIds, (goalIdEntry) =>
      _.isArray(goalIdEntry) and goal.id() in goalIdEntry
    
    addGoalOptions.sidewaysIndex = sidewaysIndex if sidewaysIndex >= 0
    
    @studyPlan.addGoal addGoalOptions
