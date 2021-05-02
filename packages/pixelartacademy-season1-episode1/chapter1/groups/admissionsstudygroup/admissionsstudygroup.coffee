AE = Artificial.Everywhere
AB = Artificial.Babel
ABs = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

# Uses membership to determine its members for the current character.
class C1.Groups.AdmissionsStudyGroup extends PAA.Groups.HangoutGroup
  # lastIntroducedMemberId: the member ID for the last PC the coordinator introduced during a follow-up meeting.
  @fullName: -> "admissions study group"

  @letter: ->  _.last @id()

  @listeners: ->
    super(arguments...).concat [
      @HangoutGroupListener
    ]

  @coordinator: -> throw new AE.NotImplementedException "You must provide who coordinates this group."
  @coordinatorInMeetingSpace: -> @coordinator()

  @getCharacterMembership: (characterId) ->
    LOI.Character.Membership.documents.findOne
      groupId: /PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup/
      'character._id': characterId
    ,
      sort:
        joinTime: -1

  @introduceMember: (agentId, script, nextAgentCallback) ->
    agent = LOI.Character.getAgent agentId

    # Mark agent as met and introduced.
    agent.personState 'alreadyMet', true
    agent.personState 'introduced', true

    # Record hangout with agent.
    agent.recordHangout()

    # If the agent has no previous hangout, set it to their group join date. This way they will report
    # their progress at the first study group meeting the player sees, if this agent joined later.
    unless agent.personState 'previousHangout'
      membership = @getCharacterMembership agentId
      agent.personState 'previousHangout', time: membership.joinTime.getTime()

    # See if this agent made a custom introduction.
    if introductionAction = C1.CoordinatorAddress.CharacterIntroduction.latestIntroductionForCharacter.query(agentId).fetch()[0]
      # Agent says the introduction directly.
      dialogueLine = new Nodes.DialogueLine
        actor: agent
        line: introductionAction.content.introduction
        next: new Nodes.Callback
          callback: (complete) =>
            complete()
            nextAgentCallback()

      LOI.adventure.director.startNode dialogueLine

    else
      # Agent does the default introduction.
      script.setThings pc: agent

      LOI.adventure.director.startScript script, label: 'DefaultIntroduction'

  # Subscriptions

  @groupMembers = new ABs.Subscription
    name: "PAA.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.groupMembers"
    query: (characterId, groupId) =>
      # Get the latest study group membership of character.
      characterMembership = @getCharacterMembership characterId

      if characterMembership
        if characterMembership.groupId is groupId
          # The character is requesting to find members of their own study group.
          memberId = characterMembership.memberId

        else
          # The character is requesting to find members of another study group. We should show the members that he
          # encountered during admission week, so we center the group around the character who joined at the same time
          # they did.
          joinTime = characterMembership.joinTime

      else
        # The character has not joined a group yet, so we just show the latest members of the study group.
        joinTime = new Date()

      unless memberId
        membership = LOI.Character.Membership.documents.findOne
          groupId: groupId
          joinTime:
            $lte: joinTime
        ,
          sort:
            memberId: -1

        # Get the latest member's number, or default to one (will return first three members).
        memberId = membership?.memberId or 1

      # Study group has 2 characters before and after the center character.
      LOI.Character.Membership.documents.find
        groupId: groupId
        memberId:
          $gte: memberId - 2
          $lte: memberId + 2

  constructor: ->
    super arguments...

    # Subscribe to admission action for the agents so that we can determine who are active members.
    @_admissionTaskEntrySubscription = Tracker.autorun (computation) =>
      agentIds = (agent._id for agent in @otherAgents())
      PAA.Learning.Task.Entry.forCharactersTaskId.subscribe agentIds, C1.Goals.Admission.Complete.id()

  destroy: ->
    super arguments...

    @_admissionTaskEntrySubscription.stop()

  agents: ->
    agents = @constructor.groupMembers.query(LOI.characterId(), @constructor.id()).map (membership) =>
      LOI.Character.getAgent membership.character._id

    @_excludeAdmittedMembers agents

  otherAgents: ->
    _.without @agents(), LOI.agent()

  actors: ->
    actors = for npcClass in @constructor.npcMembers()
      LOI.adventure.getThing npcClass

    @_excludeAdmittedMembers actors

  members: ->
    [@otherAgents()..., @actors()...]

  presentMembers: ->
    presentMembers = super arguments...

    # Include unintroduced members even if they had no recent actions.
    for member in @unintroducedMembers()
      agent = LOI.Character.getAgent member.character._id
      presentMembers.push agent unless agent in presentMembers

    presentMembers

  unintroducedMembers: ->
    characterId = LOI.characterId()
    return [] unless characterMembership = @constructor.getCharacterMembership characterId

    lastIntroducedMemberId = @state('lastIntroducedMemberId') or characterMembership.memberId

    members = @constructor.groupMembers.query(characterId, @constructor.id()).fetch()

    member for member in members when member.memberId > lastIntroducedMemberId

  _excludeAdmittedMembers: (members) ->
    # Exclude members that have had their acceptance celebration since they should stop coming to the meetings.
    _.filter members, (member) =>
      not member.personState()?.admissionWeekAcceptanceCelebrationCompleted

  things: ->
    # Study group isn't active until the mixer is over.
    return [] unless C1.Mixer.finished()

    [
      @presentMembers()...
      @constructor.coordinatorInMeetingSpace()
    ]

  listenForReciprocityAsk: (@_reciprocityAskCompleteCallback) ->
    groupListener = @_getGroupListener()
    groupListener.listenForReciprocityAsk = true
    groupListener.groupScript.ephemeralState 'reciprocityAsked', false

  listenForReciprocityReply: (@_reciprocityReplyCompleteCallback) ->
    groupListener = @_getGroupListener()
    groupListener.listenForReciprocityReply = true
    groupListener.groupScript.ephemeralState 'reciprocityReplied', false

  introduceNextAgent: ->
    groupListener = @_getGroupListener()

    unless agentId = @_agentIdsLeftForIntruductions.shift()
      # Continue to the rest of the meeting.
      LOI.adventure.director.startScript groupListener.groupScript, label: 'IntroductionsEnd'
      return

    @constructor.introduceMember agentId, groupListener.groupScript, =>
      member = @constructor.getCharacterMembership agentId

      # Temporarily store that we've introduced this person, so
      # that we can update it in the state at the end of the meeting.
      @_newLastIntroducedMemberId = member.memberId

      @introduceNextAgent()

  _getGroupListener: ->
    _.find @listeners, (listener) => listener instanceof @constructor.HangoutGroupListener

  updateLastIntroducedMemberId: ->
    return unless @_newLastIntroducedMemberId

    @state 'lastIntroducedMemberId', @_newLastIntroducedMemberId
    @_newLastIntroducedMemberId = null

  # Listener

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Subscribe to see group members.
    @_studyGroupMembershipSubscription = C1.Groups.AdmissionsStudyGroup.groupMembers.subscribe LOI.characterId(), scene.id()

    # Subscribe to group members' introductions.
    @autorun (computation) =>
      for member in scene.unintroducedMembers()
        C1.CoordinatorAddress.CharacterIntroduction.latestIntroductionForCharacter.subscribe member.character._id

  cleanup: ->
    super arguments...

    @_studyGroupMembershipSubscription?.stop()
    @_conversationMemoriesSubscription?.stop()

  # Hangout group parts

  class @HangoutGroupListener extends PAA.Groups.HangoutGroup.GroupListener
    @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.HangoutGroupListener"

    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode1/chapter1/groups/admissionsstudygroup/admissionsstudygroup.script'
    ]

    class @Script extends PAA.Groups.HangoutGroup.GroupListener.Script
      @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup"
      @initialize()

    @initialize()

    onScriptsLoaded: ->
      super arguments...

      scene = @options.parent
      group = scene

      @groupScript.setCurrentThings
        coordinator: scene.constructor.coordinatorInMeetingSpace()

      @groupScript.setCallbacks
        IntroduceNext: (complete) =>
          complete()
          scene.introduceNextAgent()

        ReportProgress: (complete) =>
          # Pause current callback node so dialogues can execute.
          LOI.adventure.director.pauseCurrentNode()

          # Record that your PC has reported progress.
          person = LOI.agent()
          person.recordHangout()

          group.characterUpdatesHelper.person person

          script = group.personUpdates.getScript
            person: person
            # Don't use the default text when player has no updates, we'll use a custom one.
            justUpdate: true
            readyField: group.characterUpdatesHelper.ready
            nextNode: null
            endUpdateCallback: =>
              # Transfer learning tasks information.
              learningTasks = script.ephemeralState 'learningTasks'
              @groupScript.ephemeralState 'learningTasks', learningTasks

              # See if there were any tasks reported at all.
              nothingToReport = script.ephemeralState('relevantUpdatesCount') is 0
              @groupScript.ephemeralState 'nothingToReport', nothingToReport

              complete()

          LOI.adventure.director.startScript script, label: 'JustUpdateStart'

        ReciprocityStart: (complete) =>
          # Analyze participant's actions and subscribe to mentioned study group conversations.
          conversationMemoryIds = []

          for agent in scene.otherAgents()
            conversationActions = _.filter agent.recentActions(), (action) => action.contextId is C1.Groups.AdmissionsStudyGroup.Conversation.id()
            agentConversationMemoryIds = (action.memory._id for action in conversationActions)
            conversationMemoryIds = _.union conversationMemoryIds, agentConversationMemoryIds

          scene._conversationMemoriesSubscription = LOI.Memory.forIds.subscribe scene, conversationMemoryIds

          complete()

        ReciprocityAsk: (complete) =>
          # Pause current callback node so player can perform the say command.
          LOI.adventure.director.pauseCurrentNode()

          scene.listenForReciprocityAsk complete

        ReciprocityOtherAsks: (complete) =>
          # Make sure all the memories have loaded.
          Tracker.autorun (computation) =>
            return unless scene._conversationMemoriesSubscription.ready()

            # Find out how many other members have started study group conversations since last meeting.
            @_otherAsks = []

            for agent in scene.otherAgents()
              actions = _.reverse _.sortBy agent.recentActions(), (action) -> action.time
              lastConversationStarter = _.find actions, (action) =>
                return unless action.contextId is C1.Groups.AdmissionsStudyGroup.Conversation.id()

                # See if this action is starting its memory.
                return unless memory = LOI.Memory.documents.findOne action.memory._id

                action._id is memory.chronologicalActions()[0]._id

              if lastConversationStarter
                @_otherAsks.push
                  agent: agent
                  memory: LOI.Memory.documents.findOne lastConversationStarter.memory._id

            @groupScript.ephemeralState 'otherAsksLeft', @_otherAsks.length

            computation.stop()
            complete()

        ReciprocityOtherAsksStart: (complete) =>
          otherAsk = @_otherAsks.shift()
          @groupScript.ephemeralState 'otherAsksLeft', @_otherAsks.length

          # Create a script where the person says the actions and then continues to the rest of the script.
          lastNode = new Nodes.Callback
            callback: (callbackComplete) =>
              callbackComplete()
              complete()

          for action in _.reverse otherAsk.memory.chronologicalActions()
            # Cast into correct type.
            action = action.cast()
            agent = LOI.Character.getAgent(action.character._id)

            # Start and end the action (in reverse order).
            actionEndScript = action.createEndScript agent, lastNode, immediate: false
            lastNode = actionEndScript if actionEndScript

            actionStartScript = action.createStartScript agent, lastNode, immediate: false
            lastNode = actionStartScript if actionStartScript

          # Advertise conversation context.
          context = LOI.Memory.Context.createContext otherAsk.memory
          LOI.adventure.advertiseContext context

          LOI.adventure.director.pauseCurrentNode()
          LOI.adventure.director.startNode lastNode

        ReciprocityOtherAsksReply: (complete) =>
          # Pause current callback node so player can perform the say command.
          LOI.adventure.director.pauseCurrentNode()

          scene.listenForReciprocityReply complete

        AcceptanceCelebrationStart: (complete) =>
          # See if any of the present members (including the character) have the admission task entry.
          playerAgent = LOI.agent()
          members = [scene.presentMembers()..., playerAgent]

          admittedMembers = _.filter members, (member) =>
            member.getTaskEntries(taskId: C1.Goals.Admission.Complete.id()).length

          # Since the player character can come back after they went through the acceptance
          # celebration, we need to remove them to prevent celebrating again.
          if @groupScript.state 'AcceptanceCelebrationPlayer'
            _.pull admittedMembers, playerAgent

          if admittedMembers.length
            acceptanceCelebration =
              studentsCount: admittedMembers.length
              names: AB.Rules.English.createNounSeries (member.fullName() for member in admittedMembers)
              player: playerAgent in admittedMembers

          else
            # Note: We need to specifically null this value to override any previous acceptance celebration state.
            acceptanceCelebration = null

          @groupScript.ephemeralState 'acceptanceCelebration', acceptanceCelebration

          complete()

        AcceptanceCelebrationComplete: (complete) =>
          admittedMembers = _.filter scene.presentMembers(), (member) =>
            member.getTaskEntries(taskId: C1.Goals.Admission.Complete.id()).length

          for member in admittedMembers
            personState = member.personState()
            personState.admissionWeekAcceptanceCelebrationCompleted = true

          LOI.adventure.gameState.updated()

          complete()

        MeetingEnd: (complete) =>
          # Update members that have been introduced.
          scene.updateLastIntroducedMemberId()

          complete()

    onCommand: (commandResponse) ->
      super arguments...

      scene = @options.parent

      doSayAction = (context, memoryId, likelyAction, sayPerformedStateVariable, completeCallback) =>
        # Remove text from narrative since it will be displayed from the script.
        LOI.adventure.interface.narrative.removeLastCommand()

        # Add the Say action.
        timelineId = LOI.adventure.currentTimelineId()
        locationId = LOI.adventure.currentLocationId()

        contextId = context.id()
        situation = {timelineId, locationId, contextId}

        message = _.trim _.last(likelyAction.translatedForm), '"'

        content =
          say:
            text: message

        LOI.Memory.Action.do LOI.Memory.Actions.Say.type, LOI.characterId(), situation, content, memoryId

        LOI.adventure.enterContext context

        # Add a hint to continue with the meeting. Use a delay so that context script happens first.
        Meteor.setTimeout =>
          LOI.adventure.director.startScript @groupScript, label: 'ContinueMeetingHint'
        ,
          100

        Tracker.autorun (computation) =>
          return if LOI.adventure.currentContext()
          computation.stop()

          # Mark that a say command was performed.
          @groupScript.ephemeralState sayPerformedStateVariable, true

          # Continue with the script.
          completeCallback()

      if @listenForReciprocityAsk and not LOI.adventure.currentContext()
        # Hijack the say command.
        sayAction = (likelyAction) =>
          @listenForReciprocityAsk = false

          # Create a new conversation memory.
          context = new C1.Groups.AdmissionsStudyGroup.Conversation()
          memoryId = context.displayNewMemory()

          doSayAction context, memoryId, likelyAction, 'reciprocityAsked', scene._reciprocityAskCompleteCallback

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.Say, '""']
          priority: 1
          action: sayAction

        # Also hijack just quotes.
        commandResponse.onPhrase
          form: ['""']
          priority: 1
          action: sayAction

        # React to back and continue if the player changes their mind and does not use the say command.
        commandResponse.onExactPhrase
          form: [[Vocabulary.Keys.Directions.Back, Vocabulary.Keys.Verbs.Continue]]
          priority: -1
          action: =>
            @listenForReciprocityAsk = false
            scene._reciprocityAskCompleteCallback()

      if @listenForReciprocityReply and not LOI.adventure.currentContext()
        # Hijack the say command.
        sayAction = (likelyAction) =>
          @listenForReciprocityReply = false

          # Add the reply to the advertised context.
          context = LOI.adventure.advertisedContext()
          memoryId = context.memoryId()

          doSayAction context, memoryId, likelyAction, 'reciprocityReplied', scene._reciprocityReplyCompleteCallback

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.Say, '""']
          priority: 1
          action: sayAction

        # Also hijack just quotes.
        commandResponse.onPhrase
          form: ['""']
          priority: 1
          action: sayAction

        # React to back and continue if the player changes their mind and does not use the say command.
        commandResponse.onExactPhrase
          form: [[Vocabulary.Keys.Directions.Back, Vocabulary.Keys.Verbs.Continue]]
          priority: -1
          action: =>
            @listenForReciprocityReply = false
            scene._reciprocityReplyCompleteCallback()

      # If the student already graduated, have a different intro.
      alreadyAccepted = @groupScript.state 'AcceptanceCelebrationPlayer'
      notOwnGroup = scene.constructor.id() isnt C1.readOnlyState 'studyGroupId'

      if alreadyAccepted
        alreadyAcceptedLabel = if notOwnGroup then 'AlreadyAcceptedNotOwnGroup' else 'AlreadyAccepted'

      else if notOwnGroup
        alreadyAcceptedLabel = 'NotOwnGroup'

      if alreadyAcceptedLabel
        commandResponse.onPhrase
          form: [[Vocabulary.Keys.Verbs.HangOut, Vocabulary.Keys.Verbs.SitDown]]
          priority: 1
          action: =>
            # Prepare all data for the hangout.
            startScriptOptions = @prepareHangout()

            # Override the start to the new already-accepted script.
            startScriptOptions.label = alreadyAcceptedLabel
            LOI.adventure.director.startScript @groupScript, startScriptOptions

    prepareHangout: ->
      scene = @options.parent

      # See if new members must be introduced.
      unintroducedMembers = scene.unintroducedMembers()

      scene._agentIdsLeftForIntruductions = (member.character._id for member in unintroducedMembers)
      unintroducedAgents = (LOI.Character.getAgent id for id in scene._agentIdsLeftForIntruductions)

      newMembers =
        count: unintroducedMembers.length
        names: AB.Rules.English.createNounSeries (agent.fullName() for agent in unintroducedAgents)

      @groupScript.ephemeralState 'newMembers', newMembers

      super arguments...
