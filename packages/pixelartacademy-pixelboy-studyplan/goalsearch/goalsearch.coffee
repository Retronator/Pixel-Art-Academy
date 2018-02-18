AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.StudyPlan.GoalSearch extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.GoalSearch'
  @register @id()

  onCreated: ->
    super
    
    @studyPlan = @ancestorComponentOfType PAA.PixelBoy.Apps.StudyPlan

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
    
  events: ->
    super.concat
      'mousedown .pixelartacademy-pixelboy-apps-studyplan-goal': @onMouseDownGoal

  onMouseDownGoal: (event) ->
    goal = @currentData()

    # Prevent browser select/dragging behavior
    event.preventDefault()

    # Add this goal to the canvas.
    @studyPlan.addGoal
      goal: goal
      element: event.currentTarget
      event: event
