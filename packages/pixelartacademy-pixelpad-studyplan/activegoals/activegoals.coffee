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
    
    @activeAndAvailableGoals = new ComputedField =>
      return [] unless goalsData = StudyPlan.state 'goals'
      
      goals = []

      for goalId, goalData of goalsData
        goal = PAA.Learning.Goal.getAdventureInstanceForId goalId
        goals.push goal if goal.activeAndAvailable()
      
      _.sortBy goals, (goal) => _.lowerCase goal.displayName()

  canRemove: ->
    goal = @currentData()
    StudyPlan.canRemoveGoal goal.id()
  
  events: ->
    super(arguments...).concat
      'click .goal .name': @onClickGoalName
    
  onClickGoalName: (event) ->
    goal = @currentData()
    @studyPlan.selectGoal goal.id()
