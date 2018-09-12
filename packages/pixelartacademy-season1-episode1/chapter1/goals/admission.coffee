PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.Admission extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Admission'

  @displayName: -> "Get admitted"

  @chapter: -> C1
    
  Goal = @

  class @Complete extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Admission.Complete'
    @goal: -> Goal

    @directive: -> "Complete admission week"

    @instructions: -> """
      Set and meet your commitment goal, create your Retropolis profile, create a goal hiearchy in the study plan, 
      learn to use drawing tools of choice, and complete one of the admission projects. 
    """

    @interests: -> ['academy of art admission']

    @requiredInterests: -> ['study plan', 'desired drawing time', 'academy of art admission project', 'study group']

    @initialize()

  @tasks: -> [
    @Complete
  ]

  @finalTasks: -> [
    @Complete
  ]

  @initialize()
