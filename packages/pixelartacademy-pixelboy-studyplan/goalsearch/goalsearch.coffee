AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan.GoalSearch extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.GoalSearch'
  @register @id()

  onCreated: ->
    super

    # Instantiate all goals.
    goalClasses = PAA.Learning.Goal.getClasses()

    @goals = []
    @goalsById = {}

    for goalClass in goalClasses
      goal = new goalClass
      @goals.push goal
      @goalsById[goal.id()] = goal

  onDestroyed: ->
    goal.destroy() for goal in @goals

  results: ->
    @goals()
