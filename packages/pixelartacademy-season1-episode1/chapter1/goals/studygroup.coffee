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

    @completedConditions: ->
      PAA.PixelPad.Apps.Yearbook.state 'profileFormOpened'

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

  class @MeetClassmates extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.MeetClassmates'
    @goal: -> Goal

    @directive: -> "Meet your classmates"

    @instructions: -> """
      Go to Retronator HQ gallery for a social mixer with other applicants.
    """

    @predecessors: -> [Goal.Yearbook]

    @initialize()

    @completedConditions: ->
      C1.Mixer.GalleryWest.scriptState 'MixerStart'

  class @JoinStudyGroup extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.JoinStudyGroup'
    @goal: -> Goal

    @directive: -> "Join study group"

    @instructions: -> """
      At the mixer, choose one of the admission week study groups.
    """

    @predecessors: -> [Goal.MeetClassmates]

    @initialize()

    @completedConditions: ->
      C1.readOnlyState 'studyGroupId'

  class @AttendIntroductoryMeeting extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.AttendIntroductoryMeeting'
    @goal: -> Goal

    @directive: -> "Attend introductory meeting"

    @instructions: -> """
      Go to your group's meeting space and complete the introductory meeting.
    """

    @interests: -> ['study group']

    @predecessors: -> [Goal.JoinStudyGroup]

    @initialize()

    @completedConditions: -> C1.CoordinatorAddress.finished()

  class @HangOutWithGroup extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.HangOutWithGroup'
    @goal: -> Goal

    @directive: -> "Hang out with your study group"

    @instructions: -> """
      Come back to the group's meeting space and report on your progress.
    """

    @predecessors: -> [Goal.AttendIntroductoryMeeting]

    @groupNumber: -> 1

    @initialize()

    @completedConditions: -> C1.Groups.AdmissionsStudyGroup.HangoutGroupListener.Script.state 'ReportProgress'

  class @Reciprocity extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.StudyGroup.Reciprocity'
    @goal: -> Goal

    @directive: -> "Interact during the reciprocity round"

    @instructions: -> """
      Share something with the group or reply to your classmates' messages during the reciprocity part of a study group meeting.
    """

    @predecessors: -> [Goal.HangOutWithGroup]

    @groupNumber: -> 1

    @initialize()

    @completedConditions: -> _.some [
      C1.Groups.AdmissionsStudyGroup.HangoutGroupListener.Script.state 'ReciprocityOtherAsksRepliedSuccessfully'
      C1.Groups.AdmissionsStudyGroup.HangoutGroupListener.Script.state 'ReciprocityAskThankYou'
    ]

  @tasks: -> [
    @Yearbook
    # TODO: Add privacy settings.
    # @SetPrivacySettings
    @MeetClassmates
    @JoinStudyGroup
    @AttendIntroductoryMeeting
    @HangOutWithGroup
    @Reciprocity
  ]

  @finalTasks: -> [
    @AttendIntroductoryMeeting
  ]

  @initialize()
