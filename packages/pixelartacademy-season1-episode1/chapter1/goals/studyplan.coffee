PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.StudyPlan extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyPlan'

  @displayName: -> "Start study plan"

  Goal = @

  class @ChooseAdmissionProject extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyPlan.ChooseAdmissionProject'

    @directive: -> "Choose admission project"

    @instructions: -> """
      Search for admission projects and drag one into your study plan. Click on the project name to show the goal's tasks.
      Drag an arrow from the ending plus sign to the admission goal.
    """

    @initialize()

  class @PlanAdmissionProjectRequirements extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyPlan.PlanAdmissionProjectRequirements'

    @directive: -> "Plan admission project requirements"

    @instructions: -> """
      Click on each of the requirements in the admission project and add study plan goals that provide that requirement.
      Connect them with arrows to your admission project.
    """

    @predecessors: -> [Goal.ChooseAdmissionProject]

    @initialize()

  class @PlanAllRequirements extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyPlan.PlanAllRequirements'

    @directive: -> "Plan all requirements"

    @instructions: -> """
      Over time, plan goals to meet all requirements in your study plan.
    """

    @interests: -> ['study plan']

    @predecessors: -> [Goal.PlanAdmissionProjectRequirements]

    @initialize()

  @tasks: -> [
    @ChooseAdmissionProject
    @PlanAdmissionProjectRequirements
    @PlanAllRequirements
  ]

  @finalTasks: -> [
    @PlanAllRequirements
  ]

  @initialize()
