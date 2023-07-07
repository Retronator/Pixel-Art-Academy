AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class PAA.PixelPad.Apps.AdmissionWeek.DayView extends PAA.PixelPad.Apps.AdmissionWeek.DayView
  @register @id()

  onCreated: ->
    super arguments...

    # Subscribe to character's study group members.
    @autorun (computation) =>
      return unless studyGroupId = C1.readOnlyState 'studyGroupId'
      C1.Groups.AdmissionsStudyGroup.groupMembers.subscribe LOI.characterId(), studyGroupId

    @studyGroupClass = new ComputedField =>
      return unless studyGroupId = C1.readOnlyState 'studyGroupId'

      LOI.Adventure.Thing.getClassForId studyGroupId

    @studyGroupCoordinatorAvatar = new ComputedField =>
      return unless groupClass = @studyGroupClass()
      groupClass.coordinator().createAvatar()

    @studyGroupLocationAvatar = new ComputedField =>
      return unless groupClass = @studyGroupClass()
      groupClass.location().createAvatar()

    @studyGroupNPCMemberAvatars = new ComputedField =>
      return unless groupClass = @studyGroupClass()
      member.createAvatar() for member in groupClass.npcMembers()

    @admissionProjectGoalClasses = _.filter PAA.Learning.Goal.getClasses(), (goalClass) => 'academy of art admission project' in goalClass.interests()

  # Commitment goal

  commitmentGoalCompletedClass: ->
    'completed' if @_getGoalForClass(C1.Goals.Time)?.completed()

  commitmentGoal: ->
    goal = _.pick PAA.PixelPad.Apps.Calendar.state('weeklyGoals'), ['daysWithActivities', 'totalHours']

    # Goal is not valid if at least one of the options has a value.
    return unless goal.daysWithActivities or goal.totalHours

    goalDescriptions = []

    if goal.daysWithActivities
      amountText = if goal.daysWithActivities is 1 then "1 day" else "#{goal.daysWithActivities} days"
      goalDescriptions.push "#{amountText} with activities"

    if goal.totalHours
      amountText = if goal.totalHours is 1 then "1 total hour" else "#{goal.totalHours} total hours"
      goalDescriptions.push amountText

    goal.description = goalDescriptions.join " and "

    goal

  weeklyGoalValueClass: ->
    return 'not-completed' unless C1.Goals.Time.SetDesiredTime.completedConditions()

    # Set as completed if the goals are met.
    weeklyGoals = PAA.PixelPad.Apps.Calendar.state 'weeklyGoals'
    completed = true

    completed = false if weeklyGoals.daysWithActivities and @daysActive() < weeklyGoals.daysWithActivities
    completed = false if weeklyGoals.totalHours and @hoursActive() < weeklyGoals.totalHours

    'completed' if completed

  daysActive: ->
    C1.Goals.Time.ReachDesiredTime.daysWithActivitiesInLast7Days()

  daysActiveValueClass: ->
    return unless daysWitActivities = PAA.PixelPad.Apps.Calendar.state('weeklyGoals')?.daysWithActivities

    @_valueClassTrueOrFalse @daysActive() >= daysWitActivities

  hoursActive: ->
    C1.Goals.Time.ReachDesiredTime.totalHoursInLast7Days()

  hoursActiveValueClass: ->
    return unless totalHours = PAA.PixelPad.Apps.Calendar.state('weeklyGoals')?.totalHours

    @_valueClassTrueOrFalse @hoursActive() >= totalHours

  # Study plan

  studyPlanCompletedClass: ->
    'completed' if @_getGoalForClass(C1.Goals.StudyPlan)?.completed()

  admissionGoalAdded: -> C1.Goals.StudyPlan.AddAdmissionGoal.completedConditions()
  admissionGoalAddedValueClass: -> @_valueClassTrueOrFalse @admissionGoalAdded()

  prerequisitesPlaned: -> C1.Goals.StudyPlan.PlanAllRequirements.completedConditions()
  prerequisitesPlanedValueClass: -> @_valueClassTrueOrFalse @prerequisitesPlaned()

  # Study group

  studyGroupCompletedClass: ->
    return unless studyGroupGoal = @_getGoalForClass C1.Goals.StudyGroup

    'completed' if studyGroupGoal.completed()

  studyGroup: ->
    return unless studyGroupId = C1.readOnlyState 'studyGroupId'

    npcMembers = (member.fullName() for member in @studyGroupNPCMemberAvatars())

    playerMemberships = C1.Groups.AdmissionsStudyGroup.groupMembers.query(LOI.characterId(), studyGroupId).fetch()
    playerMembers = for membership in playerMemberships
      if membership.character._id is LOI.characterId()
        person = LOI.character()

      else
        person = LOI.Character.getAgent membership.character._id

      person.avatar.fullName()

    letter: _.last studyGroupId
    coordinator: @studyGroupCoordinatorAvatar().fullName()
    location: @studyGroupLocationAvatar().fullName()
    members: [npcMembers..., playerMembers...]

  joinedStudyGroupValueClass: ->
    @_valueClassTrueOrFalse @studyGroup()

  introductoryMeeting: -> C1.Goals.StudyGroup.AttendIntroductoryMeeting.completedConditions()
  introductoryMeetingValueClass: -> @_valueClassTrueOrFalse @introductoryMeeting()

  # Admission Projects

  admissionProjectCompletedClass: ->
    'completed' if @completedAdmissionProjects().length

  admissionProjectsTotal: -> @admissionProjectGoalClasses.length

  discoveredAdmissionProjects: ->
    return unless admissionProjectGoals = @_getAdmissionProjectGoals()

    discoveredAdmissionProjects = []

    for goal in admissionProjectGoals
      # Find the task without prerequisites and see if it was completed. We assume the first task is the discovery task.
      discoveryTask = _.find goal.tasks(), (task) => not task.requiredInterests().length

      discoveredAdmissionProjects.push goal if discoveryTask.completed()

    @_getGoalNames discoveredAdmissionProjects

  completedAdmissionProjects: ->
    return unless admissionProjectGoals = @_getAdmissionProjectGoals()

    completedAdmissionProjects = _.filter admissionProjectGoals, (goal) => goal.completed()
    @_getGoalNames completedAdmissionProjects

  _getAdmissionProjectGoals: ->
    return unless chapter1 = _.find LOI.adventure.currentChapters(), (chapter) => chapter instanceof C1

    for goalClass in @admissionProjectGoalClasses
      _.find chapter1.goals, (goal) -> goal instanceof goalClass

  _getGoalNames: (goals) ->
    goal.displayName() for goal in goals

  completedAdmissionProjectsValueClass: ->
    @_valueClassTrueOrFalse @completedAdmissionProjects().length

  # Helpers

  _getGoalForClass: (goalClass) ->
    return unless chapter1 = _.find LOI.adventure.currentChapters(), (chapter) => chapter instanceof C1
    _.find chapter1.goals, (goal) -> goal instanceof goalClass

  _valueClassTrueOrFalse: (value) ->
    if value then 'completed' else 'not-completed'
