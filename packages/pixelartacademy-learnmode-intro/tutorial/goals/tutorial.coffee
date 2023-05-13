LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Tutorial.Goals.Tutorial extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Tutorial'

  @displayName: -> "Complete the tutorial"

  @chapter: -> LM.Intro.Tutorial
  
  Goal = @

  class @Complete extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Tutorial.Complete'
    @goal: -> Goal

    @directive: -> "Complete the tutorial"

    @instructions: -> """
      Learn how to use the drawing editor and complete the tutorial project.
    """

    @requiredInterests: -> ['study plan', 'learn mode tutorial project']

    @completedConditions: ->
      return unless tutorial = _.find LOI.adventure.currentChapters(), (chapter) => chapter instanceof LM.Intro.Tutorial

      tutorialGoals = for goalClass in [LM.Intro.Tutorial.Goals.StudyPlan, LM.Intro.Tutorial.Goals.Snake]
        tutorial.getGoal goalClass

      _.every (goal.completed() for goal in tutorialGoals)

    @initialize()

  class @TimeTravel extends PAA.Learning.Task.Automatic.Automatic
    @id: -> 'PixelArtAcademy.LearnMode.Intro.Tutorial.Goals.Tutorial.TimeTravel'
    @goal: -> Goal

    @directive: -> "Learn about time travel"

    @instructions: -> """
      After you've completed all tutorial goals, decide where (and when?) you will start your learning journey.
    """

    @predecessors: -> [Goal.Complete]

    @interests: -> ['learn mode tutorial']

    @initialize()

    @completedConditions: ->
      LM.Intro.Tutorial.state 'timeTravelDone'

  @tasks: -> [
    @Complete
    @TimeTravel
  ]

  @finalTasks: -> [
    @TimeTravel
  ]

  @initialize()
