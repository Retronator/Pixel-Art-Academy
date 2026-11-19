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
    
    @activeGoals = new ComputedField =>
      return [] unless goalsData = StudyPlan.state 'goals'
      
      goals = []

      for goalId, goalData of goalsData
        continue unless goal = PAA.Learning.Goal.getAdventureInstanceForId goalId
        goals.push goal if goal.active()
      
      _.sortBy goals, (goal) => _.lowerCase goal.displayName()

    @shortTermGoals = new ComputedField => _.filter @activeGoals(), (goal) => StudyPlan.getGoalType(goal) is StudyPlan.GoalTypes.ShortTerm

    @midTermGoals = new ComputedField => _.filter @activeGoals(), (goal) => StudyPlan.getGoalType(goal) is StudyPlan.GoalTypes.MidTerm

    @longTermGoals = new ComputedField => _.filter @activeGoals(), (goal) => StudyPlan.getGoalType(goal) is StudyPlan.GoalTypes.LongTerm

  requiredInterests: ->
    goal = @currentData()
    return if StudyPlan.getGoalType(goal) is StudyPlan.GoalTypes.ShortTerm

    # Each initial task is an alternative way to start; all interests within that task are required.
    requiredInterestAlternatives = (task.requiredInterests() for task in goal.initialTasks())
    return if _.some requiredInterestAlternatives, (interests) => not interests.length
    requiredInterestAlternatives = _.uniqWith requiredInterestAlternatives, _.isEqual

    # Return an array of arrays (alternatives of required interests).
    for interests in requiredInterestAlternatives
      (IL.Interest.find referenceName for referenceName in interests)
  
  interestClass: ->
    interest = @currentData()
    if interest.referenceName in LOI.adventure.currentInterests() then 'acquired' else 'required'
  
  canRemove: ->
    goal = @currentData()
    StudyPlan.canRemoveGoal goal.id()
  
  events: ->
    super(arguments...).concat
      'click .goal .name': @onClickGoalName
    
  onClickGoalName: (event) ->
    goal = @currentData()
    @studyPlan.selectGoal goal.id()
