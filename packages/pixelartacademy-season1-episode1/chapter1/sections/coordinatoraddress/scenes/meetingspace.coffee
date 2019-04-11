LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class C1.CoordinatorAddress.MeetingSpace extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.CoordinatorAddress.MeetingSpace'

  @location: ->
    # Location is determined by which group the character joined.
    null

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/coordinatoraddress/scenes/meetingspace.script'

  @initialize()

  group: ->
    return unless studyGroupId = C1.readOnlyState 'studyGroupId'
    LOI.Adventure.Thing.getClassForId studyGroupId

  memberCharacterIds: ->
    return [] unless studyGroupId = C1.readOnlyState 'studyGroupId'
    return [] unless memberships = C1.Groups.AdmissionsStudyGroup.groupMembers.query(LOI.characterId(), studyGroupId)?.fetch()
    membership.character._id for membership in memberships

  location: ->
    @group().location()

  things: ->
    return unless group = @group()

    coordinator = group.coordinator()

    otherAgentIds = _.without @memberCharacterIds(), LOI.characterId()
    otherAgents = (LOI.Character.getAgent agentId for agentId in otherAgentIds)

    _.flatten [
      # Only Shelley is not at the location yet.
      coordinator if coordinator is HQ.Actors.Shelley
      group.npcMembers()
      otherAgents
    ]

  listenForCharacterIntroduction: ->
    @listeners[0].listenForCharacterIntroduction = true

  _introduceNextAgent: ->
    unless agentId = @_agentIdsLeftForIntruductions.shift()
      # Continue to the rest of the meeting.
      @listeners[0].startScript label: 'PlayerIntroduction'
      return

    agent = LOI.Character.getAgent agentId

    # Mark agent as met and introduced.
    agent.personState 'alreadyMet', true
    agent.personState 'introduced', true

    # Record hangout with agent.
    agent.recordHangout()

    # See if this agent made a custom introduction.
    if introductionAction = C1.CoordinatorAddress.CharacterIntroduction.latestIntroductionForCharacter.query(agentId).fetch()[0]
      # Agent says the introduction directly.
      dialogueLine = new Nodes.DialogueLine
        actor: agent
        line: introductionAction.content.introduction
        next: new Nodes.Callback
          callback: (complete) =>
            complete()

            @_introduceNextAgent()

      LOI.adventure.director.startNode dialogueLine

    else
      # Agent does the default introduction.
      script = @listeners[0].script
      script.setThings pc: agent

      @listeners[0].startScript label: 'DefaultIntroduction'

  # Script
    
  initializeScript: ->
    scene = @options.parent

    @setCallbacks
      AgentsIntroduction: (complete) =>
        complete()
        
        # Schedule introductions for the agents in the group before the character.
        scene._agentIdsLeftForIntruductions = _.without scene.memberCharacterIds(), LOI.characterId()
        scene._introduceNextAgent()

      DefaultIntroductionEnd: (complete) =>
        complete()
        scene._introduceNextAgent()

      PlayerIntroduction: (complete) =>
        scene.listenForCharacterIntroduction()
        complete()

      MeetingEnd: (complete) =>
        # Exit context after the section had time to end.
        Meteor.setTimeout => LOI.adventure.exitContext()
        complete()

  # Listener

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Subscribe to character's membership.
    @_characterMembershipSubscription = LOI.Character.Membership.forCharacterId.subscribe LOI.characterId()

    # Subscribe to latest group members.
    @_studyGroupMembershipSubscription = new ReactiveField null

    @_studyGroupMembershipSubscriptionAutorun = @autorun (computation) =>
      return unless studyGroupId = C1.readOnlyState 'studyGroupId'
      @_studyGroupMembershipSubscription C1.Groups.AdmissionsStudyGroup.groupMembers.subscribe LOI.characterId(), studyGroupId

    # Subscribe to group members' introductions.
    @_characterIntroductionsSubscriptions = new ReactiveField null

    @_characterIntroductionSubscriptionsAutorun = @autorun (computation) =>
      subscriptions = for characterId in scene.memberCharacterIds()
        C1.CoordinatorAddress.CharacterIntroduction.latestIntroductionForCharacter.subscribe characterId

      @_characterIntroductionsSubscriptions subscriptions

    # Player should be in the coordinator address context.
    @_enterContextAutorun = @autorun (computation) =>
      return if LOI.adventure.currentContext() instanceof C1.CoordinatorAddress.Context

      LOI.adventure.enterContext C1.CoordinatorAddress.Context
      
    # Script should start automatically when at location.
    @_scriptStartAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless group = scene.group()
      return unless coordinator = LOI.adventure.getCurrentThing group.coordinator()
      return unless coordinator.ready()

      npcMembers = group.npcMembers()
      return unless npc1 = LOI.adventure.getCurrentThing npcMembers[0]
      return unless npc2 = LOI.adventure.getCurrentThing npcMembers[1]
      return unless npc1.ready() and npc2.ready()

      return unless @_studyGroupMembershipSubscription().ready()
      return unless subscription.ready() for subscription in @_characterIntroductionsSubscriptions()

      computation.stop()

      @script.setThings {coordinator, npc1, npc2}

      C1.prepareGroupInfoInScript @script
      
      @startScriptAtLatestCheckpoint [
        'Start'
        'AgentsIntroduction'
        'PlayerIntroduction'
        'SecondNPCIntroduction'
      ]
      
  cleanup: ->
    @_characterMembershipSubscription?.stop()
    @_studyGroupMembershipSubscriptionAutorun?.stop()
    @_enterContextAutorun?.stop()
    @_scriptStartAutorun?.stop()

  onCommand: (commandResponse) ->
    if @listenForCharacterIntroduction
      # Hijack the say command.
      sayAction = (likelyAction) =>
        # Remove text from narrative since it will be displayed in a separate node.
        LOI.adventure.interface.narrative.removeLastCommand()

        introduction = _.trim _.last(likelyAction.translatedForm), '"'

        dialogueLine = new Nodes.DialogueLine
          actor: LOI.agent()
          line: introduction
          next: @script.startNode.labels.PlayerIntroductionEnd

        LOI.adventure.director.startNode dialogueLine

        # Create an action for this character's introduction.
        LOI.Memory.Action.do C1.CoordinatorAddress.CharacterIntroduction.type, LOI.characterId(),
          LOI.adventure.currentSituationParameters()
        ,
          {introduction}

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Say, '""']
        priority: 1
        action: sayAction

      # Allow hijack just quotes.
      commandResponse.onPhrase
        form: ['""']
        priority: 1
        action: sayAction
