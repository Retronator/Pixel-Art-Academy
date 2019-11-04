AE = Artificial.Everywhere
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class C1.Groups.AdmissionsStudyGroup extends PAA.Groups.HangoutGroup
  # Uses membership to determine its members for the current character.
  @fullName: -> "admissions study group"

  @listeners: ->
    super(arguments...).concat [
      @HangoutGroupListener
    ]

  @coordinator: -> throw new AE.NotImplementedException "You must provide who coordinates this group."
  @coordinatorInMeetingSpace: -> @coordinator()

  # Subscriptions

  @groupMembers = new AB.Subscription
    name: "PAA.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.groupMembers"
    query: (characterId, groupId) =>
      # Get study group membership of character.
      characterMembership = LOI.Character.Membership.documents.findOne
        groupId: /PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup/
        'character._id': characterId

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

  agents: ->
    @constructor.groupMembers.query(LOI.characterId(), @constructor.id()).map (membership) =>
      LOI.Character.getAgent membership.character._id

  otherAgents: ->
    _.without @agents(), LOI.agent()

  actors: ->
    for npcClass in @constructor.npcMembers()
      LOI.adventure.getThing npcClass

  members: ->
    [@otherAgents()..., @actors()...]

  things: ->
    # Study group isn't active until the mixer is over.
    return [] unless C1.Mixer.finished()

    [
      @presentMembers()...
      @constructor.coordinatorInMeetingSpace()
    ]

  listenForReciprocityAsk: (@_reciprocityAskCompleteCallback) ->
    groupListener = _.find @listeners, (listener) => listener instanceof @constructor.HangoutGroupListener
    groupListener.listenForReciprocityAsk = true
    groupListener.groupScript.ephemeralState 'reciprocityAsked', false

  listenForReciprocityReply: (@_reciprocityReplyCompleteCallback) ->
    groupListener = _.find @listeners, (listener) => listener instanceof @constructor.HangoutGroupListener
    groupListener.listenForReciprocityReply = true
    groupListener.groupScript.ephemeralState 'reciprocityReplied', false

  # Listener

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Subscribe to see group members.
    @_studyGroupMembershipSubscription = C1.Groups.AdmissionsStudyGroup.groupMembers.subscribe LOI.characterId(), scene.id()

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
        ReportProgress: (complete) =>
          # Pause current callback node so dialogues can execute.
          LOI.adventure.director.pauseCurrentNode()

          person = LOI.agent()

          group.characterUpdatesHelper.person person

          script = group.personUpdates.getScript
            person: person
            justUpdate: true
            readyField: group.characterUpdatesHelper.ready
            nextNode: null
            endUpdateCallback: =>
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
