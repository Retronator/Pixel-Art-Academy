AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

C1 = PAA.Season1.Episode1.Chapter1
Vocabulary = LOI.Parser.Vocabulary

class C1.Groups.AdmissionsStudyGroup.GroupmateConversation extends LOI.Adventure.Scene.ConversationBranch
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.GroupmateConversation'

  @location: ->
    # Applies to all locations, but has filtering to match your study group's members.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/groups/admissionsstudygroup/groupmateconversation.script'
  @returnLabel: -> 'MainQuestions'

  destroy: ->
    super arguments...

    @_groupmateTasksSubscription?.stop()

  prepareScriptForGroupmate: (@currentGroupmate) ->
    script = @listeners[0].script

    # Replace the groupmate with target character.
    script.setThings groupmate: @currentGroupmate

    # Transfer ephemeral state for the groupmate from main to this script.
    ephemeralPersons = script._mainScript.ephemeralState 'persons'
    ephemeralGroupmate = ephemeralPersons[@currentGroupmate._id]
    script.ephemeralState 'groupmate', ephemeralGroupmate

    # Subscribe to tasks for the groupmate.
    @_groupmateTasksSubscription?.stop()

    if @currentGroupmate instanceof LOI.Character.Agent
      @_groupmateTasksSubscription = PAA.Learning.Task.Entry.forCharacter.subscribe @currentGroupmate._id

    else
      @_groupmateTasksSubscription = null

  # Script

  initializeScript: ->
    super arguments...

    scene = @options.parent

    @setCallbacks
      WaitToLoad: (complete) =>
        Tracker.autorun (computation) =>
          return unless not scene._groupmateTasksSubscription or scene._groupmateTasksSubscription.ready()
          computation.stop()

          # Prepare data for task progress answer.

          learningTasks =
            tasks: []
            goals: []

          @ephemeralState 'learningTasks', learningTasks

          for taskEntry in scene.currentGroupmate.recentTaskEntries()
            continue unless task = PAA.Learning.Task.getAdventureInstanceForId taskEntry.taskId

            goal = _.find learningTasks.goals, (goal) => goal.id is task.goal.id()

            unless goal
              goal =
                id: task.goal.id()
                displayName: "'#{task.goal.displayName()}'"

              learningTasks.goals.push goal

            learningTasks.tasks.push
              directive: "'#{task.directive()}'"
              goal: goal

          learningTasks.taskDirectives = AB.Rules.English.createNounSeries (task.directive for task in learningTasks.tasks)
          learningTasks.goalNames = AB.Rules.English.createNounSeries (goal.displayName for goal in learningTasks.goals)

          # Prepare data for completed goals answer.

          completedGoals = []
          taskEntries = scene.currentGroupmate.getTaskEntries()

          for taskEntry in taskEntries
            continue unless task = PAA.Learning.Task.getAdventureInstanceForId taskEntry.taskId
            continue if _.find completedGoals, (goal) => goal.id is task.goal.id()

            # See if this task is a final task for the goal.
            continue unless task.constructor in task.goal.constructor.finalTasks()

            completedGoals.push task.goal

          @ephemeralState 'completedGoals', AB.Rules.English.createNounSeries (goal.displayName() for goal in completedGoals)
          @ephemeralState 'completedGoalsCount', completedGoals.length

          # Prepare data for commitment goal answer.

          weeklyGoals = scene.currentGroupmate.instance.document().profile?.weeklyGoals

          # Round any fractional values to 1 digit. Note that the result is a string.
          weeklyGoals[property] = value.toFixed 1 for property, value of weeklyGoals when value % 1 isnt 0

          @ephemeralState 'weeklyGoals', weeklyGoals

          # Prepare data for admission project answer.
          taskEntries = _.sortBy taskEntries, 'time'

          admissionProject = null

          for taskEntry in taskEntries by -1
            continue unless task = PAA.Learning.Task.getAdventureInstanceForId taskEntry.taskId
            goal = task.goal

            if _.find(goal.constructor.tasks(), (taskClass) => 'academy of art admission project' in taskClass.interests())
              admissionProject = goal.displayName()
              break

          @ephemeralState 'admissionProject', admissionProject

          complete()

  # Listener

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Subscribe to see group members.
    @_studyGroupMembershipAutorun = Tracker.autorun (computation) =>
      return unless studyGroupId = C1.readOnlyState 'studyGroupId'
      C1.Groups.AdmissionsStudyGroup.groupMembers.subscribe LOI.characterId(), studyGroupId

  cleanup: ->
    super arguments...

    @_studyGroupMembershipAutorun?.stop()

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    super arguments...

    scene = @options.parent

    return unless choicePlaceholderResponse.placeholderId is 'PersonConversationMainQuestions'

    # This choices only apply to members of your study group.
    return unless studyGroupId = C1.readOnlyState 'studyGroupId'
    group = LOI.adventure.getThing studyGroupId
    members = group.members()

    person = choicePlaceholderResponse.script.things.person
    return unless person in members
    groupmate = person

    # Save the script so we can access its ephemeral state.
    @script._mainScript = choicePlaceholderResponse.script

    choicePlaceholderResponse.addChoices @script.startNode.labels.MainQuestions.next

    # Prepare script for talking about this groupmate.
    Tracker.nonreactive => scene.prepareScriptForGroupmate groupmate
