PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.StudyGroup extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup'

  @displayName: -> "Join a study group"

  @chapter: -> C1

  Goal = @

  class @Yearbook extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.Yearbook'
    @goal: -> Goal

    @directive: -> "Create Yearbook profile"

    @instructions: -> """
      Find the Personal profile card in the Yearbook app and set any extra information you want to share with your classmates.
    """

    @initialize()

    completedConditions: ->
      PAA.PixelBoy.Apps.Yearbook.state 'profileFormOpened'

  class @SetPrivacySettings extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.SetPrivacySettings'
    @goal: -> Goal

    @directive: -> "Set privacy settings"

    @instructions: -> """
      Look over privacy settings in the Yearbook app to choose how others can interact with you.
    """

    @predecessors: -> [Goal.Yearbook]

    @groupNumber: -> 1

    @initialize()

  class @MeetClassmates extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.MeetClassmates'
    @goal: -> Goal

    @directive: -> "Meet your classmates"

    @instructions: -> """
      Go to Retronator HQ gallery for a social mixer with other applicants.
    """

    @predecessors: -> [Goal.Yearbook]

    @initialize()

  class @JoinStudyGroup extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.JoinStudyGroup'
    @goal: -> Goal

    @directive: -> "Join study group"

    @instructions: -> """
      At the mixer, choose one of the admission week study groups
    """

    @interests: -> ['study group']

    @predecessors: -> [Goal.MeetClassmates]

    @initialize()

  @tasks: -> [
    @Yearbook
    # TODO: Add privacy settings.
    # @SetPrivacySettings
    @MeetClassmates
    @JoinStudyGroup
  ]

  @finalTasks: -> [
    @JoinStudyGroup
  ]

  @initialize()
