PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.StudyGroup extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup'

  @displayName: -> "Join a study group"

  @chapter: -> C1

  Goal = @

  class @Yearbook extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.Yearbook'

    @directive: -> "Create Yearbook profile"

    @instructions: -> """
      Add your name to the Yearbook and set any extra information you want to share with your classmates.
    """

    @initialize()

  class @SetPrivacySettings extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.SetPrivacySettings'

    @directive: -> "Set privacy settings"

    @instructions: -> """
      Look over privacy settings in the Yearbook app to choose how others can interact with you.
    """

    @predecessors: -> [Goal.Yearbook]

    @groupNumber: -> 1

    @initialize()

  class @MeetClassmates extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.MeetClassmates'

    @directive: -> "Meet your classmates"

    @instructions: -> """
      Go to Retronator HQ gallery for a social mixer with other applicants.
    """

    @predecessors: -> [Goal.Yearbook]

    @initialize()

  class @JoinStudyGroup extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.JoinStudyGroup'

    @directive: -> "Join study group"

    @instructions: -> """
      At the mixer, choose one of the admission week study groups
    """

    @interests: -> ['study group']

    @predecessors: -> [Goal.MeetClassmates]

    @initialize()

  @tasks: -> [
    @Yearbook
    @SetPrivacySettings
    @MeetClassmates
    @JoinStudyGroup
  ]

  @finalTasks: -> [
    @JoinStudyGroup
  ]

  @initialize()
