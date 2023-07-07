PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.StudyPlan extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyPlan'

  @displayName: -> "Start study plan"

  @chapter: -> C1

  Goal = @
  
  constructor: ->
    super arguments...
  
    # Add Study Plan goal to the Study Plan app.
    Tracker.autorun (computation) =>
      return unless LOI.adventure.gameState()
      computation.stop()
    
      return if PAA.PixelPad.Apps.StudyPlan.state 'goals'
  
      PAA.PixelPad.Apps.StudyPlan.state 'goals',
        "#{@id()}":
          position:
            x: -100
            y: -20
          expanded: true

  class @AddAdmissionGoal extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyPlan.AddAdmissionGoal'
    @goal: -> Goal

    @directive: -> "Add Academy of Art admission goal"

    @instructions: -> """
      Search for the "Academy of Art admission" interest and drag the "Get admitted" goal into your study plan.
    """

    @initialize()

    @completedConditions: ->
      return unless goals = PAA.PixelPad.Apps.StudyPlan.state 'goals'

      # The Admission goal must be present in the goals state.
      goals[C1.Goals.Admission.id()]

  class @ConnectStudyPlanPrerequisite extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyPlan.ConnectStudyPlanPrerequisite'
    @goal: -> Goal

    @directive: -> "Connect study plan and admission goals"

    @instructions: -> """
      Drag an arrow from the plus sign of the "Start study plan" goal to the "study plan" prerequisite of the "Get admitted" goal.
    """

    @predecessors: -> [Goal.AddAdmissionGoal]

    @initialize()

    @completedConditions: ->
      return unless goals = PAA.PixelPad.Apps.StudyPlan.state 'goals'
      return unless connections = goals[Goal.id()]?.connections

      # The connection from this goal to the admission goal must be established.
      _.find connections, (connection) => connection.goalId is C1.Goals.Admission.id() and connection.interest is 'study plan'

  class @PlanAdmissionRequirements extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyPlan.PlanAdmissionRequirements'
    @goal: -> Goal

    @directive: -> "Plan admission requirements"

    @instructions: -> """
      Click on each of the remaining prerequisites of the "Get admitted" goal and add one of the study plan goals that provide that requirement.
      Connect the new goals with arrows to the admission goal.
    """

    @predecessors: -> [Goal.ConnectStudyPlanPrerequisite]

    @initialize()

    @completedConditions: ->
      return unless goals = PAA.PixelPad.Apps.StudyPlan.state 'goals'
      goalsArray = _.values goals

      # Make sure all four required interests are wired into the admission goal.
      for requiredInterest in C1.Goals.Admission.requiredInterests()
        return unless _.find goalsArray, (goal) =>
          _.find goal.connections, (connection) =>
            connection.goalId is C1.Goals.Admission.id() and connection.interest is requiredInterest

      true

  class @PlanAllRequirements extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyPlan.PlanAllRequirements'
    @goal: -> Goal

    @directive: -> "Plan all requirements"

    @instructions: -> """
      Over time, plan goals to meet all requirements of all goals in your study plan.
    """

    @interests: -> ['study plan']

    @predecessors: -> [Goal.PlanAdmissionRequirements]

    @initialize()

    @completedConditions: ->
      return unless goals = PAA.PixelPad.Apps.StudyPlan.state 'goals'
      goalsArray = _.values goals

      # Make sure all interests of all goals are wired into the admission goal.
      for goalId, goal of goals
        # Make sure the goal has been loaded (dynamic goals aren't immediately available).
        return unless goalClass = PAA.Learning.Goal.getClassForId goalId

        for requiredInterest in goalClass.requiredInterests()
          return unless _.find goalsArray, (goal) =>
            _.find goal.connections, (connection) =>
              connection.goalId is goalId and connection.interest is requiredInterest

      true

  @tasks: -> [
    @AddAdmissionGoal
    @ConnectStudyPlanPrerequisite
    @PlanAdmissionRequirements
    @PlanAllRequirements
  ]

  @finalTasks: -> [
    @PlanAllRequirements
  ]

  @initialize()
