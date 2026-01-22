AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.ActiveGoals extends StudyPlan.BottomPanel
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.ActiveGoals'
  @register @id()

  onCreated: ->
    super arguments...
    
    @activeGoalIds = new ComputedField =>
      return [] unless goalsData = StudyPlan.state 'goals'
      
      activeGoalIds = (goalId for goalId, goal of goalsData when not goal.markedComplete)
      activeGoalIds.sort()
      activeGoalIds
    ,
      EJSON.equals
    
    @activeGoals = new ComputedField =>
      activeGoals = (PAA.Learning.Goal.getAdventureInstanceForId goalId for goalId in @activeGoalIds())
      _.sortBy activeGoals, (goal) => goal.displayName()

  canRemove: ->
    goal = @currentData()
    StudyPlan.canRemoveGoal goal.id()
  
  events: ->
    super(arguments...).concat
      'click .active-goal .name': @onClickActiveGoalName
    
  onClickActiveGoalName: (event) ->
    goal = @currentData()
    @studyPlan.selectGoal goal.id()
