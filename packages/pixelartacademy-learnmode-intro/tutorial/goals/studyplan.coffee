LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.StudyPlan extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.StudyPlan'

  @displayName: -> "Start study plan"

  @chapter: -> LM.Intro.Tutorial

  Goal = @
  
  constructor: ->
    super arguments...
  
    # Add Study Plan goal to the Study Plan app.
    Tracker.autorun (computation) =>
      return unless LOI.adventure.gameState()
      computation.stop()
    
      return if PAA.PixelBoy.Apps.StudyPlan.state 'goals'
  
      PAA.PixelBoy.Apps.StudyPlan.state 'goals',
        "#{@id()}":
          position:
            x: -100
            y: -20
          expanded: true

  class @AddTutorialGoal extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.StudyPlan.AddTutorialGoal'
    @goal: -> Goal

    @directive: -> "Add Learn Mode tutorial goal"

    @instructions: -> """
      Search for the "Learn Mode tutorial" interest and drag the "Complete the tutorial" goal into your study plan.
    """

    @initialize()

    @completedConditions: ->
      return unless goals = PAA.PixelBoy.Apps.StudyPlan.state 'goals'

      # The Tutorial goal must be present in the goals state.
      goals[LM.Intro.Tutorial.Goals.Tutorial.id()]

  class @ConnectStudyPlanPrerequisite extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.StudyPlan.ConnectStudyPlanPrerequisite'
    @goal: -> Goal

    @directive: -> "Connect Study plan and Tutorial goals"

    @instructions: -> """
      Drag an arrow from the plus sign of the "Start study plan" goal to the "study plan" prerequisite of the "Complete the tutorial" goal.
    """

    @predecessors: -> [Goal.AddTutorialGoal]

    @initialize()

    @completedConditions: ->
      return unless goals = PAA.PixelBoy.Apps.StudyPlan.state 'goals'
      return unless connections = goals[Goal.id()]?.connections

      # The connection from this goal to the tutorial goal must be established.
      _.find connections, (connection) => connection.goalId is LM.Intro.Tutorial.Goals.Tutorial.id() and connection.interest is 'study plan'

  class @PlanTutorialRequirements extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.StudyPlan.PlanTutorialRequirements'
    @goal: -> Goal

    @directive: -> "Plan tutorial requirements"

    @instructions: -> """
      Click on the remaining "learn mode tutorial project" prerequisite of the "Complete the tutorial" goal and add the "Snake game" project that will provide that requirement.
      Connect the new goal with an arrow to the Tutorial goal.
    """

    @predecessors: -> [Goal.ConnectStudyPlanPrerequisite]

    @initialize()

    @completedConditions: ->
      return unless goals = PAA.PixelBoy.Apps.StudyPlan.state 'goals'
      goalsArray = _.values goals

      # Make sure all four required interests are wired into the tutorial goal.
      for requiredInterest in LM.Intro.Tutorial.Goals.Tutorial.requiredInterests()
        return unless _.find goalsArray, (goal) =>
          _.find goal.connections, (connection) =>
            connection.goalId is LM.Intro.Tutorial.Goals.Tutorial.id() and connection.interest is requiredInterest

      true

  class @PlanAllRequirements extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.StudyPlan.PlanAllRequirements'
    @goal: -> Goal

    @directive: -> "Plan all requirements"

    @instructions: -> """
      Continue planning until all requirements have been accounted for in your study plan.
    """

    @interests: -> ['study plan']

    @predecessors: -> [Goal.PlanTutorialRequirements]

    @initialize()

    @completedConditions: ->
      return unless goals = PAA.PixelBoy.Apps.StudyPlan.state 'goals'
      goalsArray = _.values goals

      # Make sure all interests of all goals are wired into the tutorial goal.
      for goalId, goal of goals
        # Make sure the goal has been loaded (dynamic goals aren't immediately available).
        return unless goalClass = PAA.Learning.Goal.getClassForId goalId

        for requiredInterest in goalClass.requiredInterests()
          return unless _.find goalsArray, (goal) =>
            _.find goal.connections, (connection) =>
              connection.goalId is goalId and connection.interest is requiredInterest

      true

  @tasks: -> [
    @AddTutorialGoal
    @ConnectStudyPlanPrerequisite
    @PlanTutorialRequirements
    @PlanAllRequirements
  ]

  @finalTasks: -> [
    @PlanAllRequirements
  ]

  @initialize()
