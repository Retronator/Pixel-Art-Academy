PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.Admission extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Admission'

  @displayName: -> "Get admitted"

  @chapter: -> C1
    
  Goal = @

  class @Complete extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Admission.Complete'
    @goal: -> Goal

    @directive: -> "Complete admission week"

    @instructions: -> """
      Set and meet your commitment goal, create your Retropolis profile, create a goal hiearchy in the study plan, 
      learn to use drawing tools of choice, and complete one of the admission projects. 
    """

    @requiredInterests: -> ['study plan', 'desired drawing time', 'academy of art admission project', 'study group']

    @completedConditions: ->
      return unless chapter1 = _.find LOI.adventure.currentChapters(), (chapter) => chapter instanceof C1

      admissionProjectGoalClasses = _.filter PAA.Learning.Goal.getClasses(), (goalClass) => 'academy of art admission project' in goalClass.interests()
      admissionGoalClasses = [C1.Goals.Time, C1.Goals.StudyPlan, C1.Goals.StudyGroup]

      getGoalsForClasses = (goalClasses) =>
        for goalClass in goalClasses
          _.find chapter1.goals, (goal) => goal instanceof goalClass

      admissionProjectGoals = getGoalsForClasses admissionProjectGoalClasses
      admissionGoals = getGoalsForClasses admissionGoalClasses

      # To complete admission week requirements you have to complete all goals and one of the admission projects.
      # TODO: Perhaps this could be better solved with checking for all required interests?
      _.every [
        _.some (goal.completed() for goal in admissionProjectGoals)
        _.every (goal.completed() for goal in admissionGoals)
      ]

    @initialize()

  class @AcceptanceCelebration extends PAA.Learning.Task.Automatic.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Admission.AcceptanceCelebration'
    @goal: -> Goal

    @directive: -> "Attend your acceptance celebration"

    @instructions: -> """
      After you've completed all four admission goals, attend a study group meeting to receive your admission letter.
    """

    @predecessors: -> [Goal.Complete]

    @interests: -> ['academy of art admission']

    @initialize()

    @completedConditions: -> false

  @tasks: -> [
    @Complete
    @AcceptanceCelebration
  ]

  @finalTasks: -> [
    @AcceptanceCelebration
  ]

  @initialize()
