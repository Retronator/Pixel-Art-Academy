LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends C1.Mixer.GalleryWest
  @initialize()

  onActivated: ->
    # Start scene after the scripts have loaded.
    Tracker.autorun (computation) =>
      return unless @listeners[0].scriptsReady()
      computation.stop()

      Tracker.nonreactive => @_startScene()

  _startScene: ->
    script = @listeners[0].script

    # Determine event phase.
    eventPhase = @eventPhase()

    # Subscribe to latest group members.
    @_studyGroupMembershipSubscription = C1.Mixer.GalleryWest.latestStudyGroupMembers.subscribe()

    # Subscribe to agents' actions.
    @_agentActionsSubscriptions = new ReactiveField null

    @_agentActionsSubscriptionsAutorun = @autorun (computation) =>
      subscriptions = for agent in @agents()
        C1.Mixer.IceBreakers.AnswerAction.latestAnswersForCharacter.subscribe agent._id

      @_agentActionsSubscriptions subscriptions

    @_positionActorsAutorun = @autorun (computation) =>
      # Wait until the location mesh has loaded, so that we have landmark positions.
      return unless LOI.adventure.world.sceneManager().currentLocationMeshData()

      # Wait until the agent actions have arrived.
      for subscription in @_agentActionsSubscriptions()
        return unless subscription.ready()

      computation.stop()

      startingPositions =
        "#{HQ.Actors.Shelley.id()}": 'InFrontOfProjector'
        "#{HQ.Actors.Reuben.id()}": 'MixerSideReuben'
        "#{HQ.Actors.Alexandra.id()}": 'MixerSideAlexandra'
        "#{HQ.Actors.Retro.id()}": 'MixerTable'

      startingFacingPositions =
        "#{HQ.Actors.Reuben.id()}": 'MixerMiddle'
        "#{HQ.Actors.Alexandra.id()}": 'MixerMiddle'

      if eventPhase is C1.Mixer.GalleryWest.EventPhases.Answering
        # Position the students based on their answer to the previous
        # question (so that they will animate to the new one).
        answerStarts = [
          'HobbyProfessionWriteStart'
          'ExtrovertIntrovertStart'
          'IndividualTeamStart'
          'ComputersConsolesStart'
        ]

        questions = [
          C1.Mixer.IceBreakers.Questions.HobbyProfession
          C1.Mixer.IceBreakers.Questions.PixelArtOtherStyles
          C1.Mixer.IceBreakers.Questions.ExtrovertIntrovert
          C1.Mixer.IceBreakers.Questions.IndividualTeam
        ]

        question = null

        for answerStart, index in answerStarts
          if script.state answerStart
            question = questions[index]

          else
            break

        for person in @students()
          # Find which answer the actor chose.
          action = person.getActions(
            type: C1.Mixer.IceBreakers.AnswerAction.type
            'content.question': question
          )[0]

          # Get either the agent's character ID or actor's thing ID.
          personId = person._id or person.id()

          startingPositions[personId] = C1.Mixer.GalleryWest.answerLandmarks[action.content.answer]
          startingFacingPositions[personId] = 'InFrontOfProjector'

      else if (eventPhase is C1.Mixer.GalleryWest.EventPhases.JoinGroup and script.state 'JoinStudyGroupContinue') or eventPhase is C1.Mixer.GalleryWest.EventPhases.CoordinatorIntro
        # Position students in their groups.
        for actorClass in @constructor.actorClasses
          groupIndex = _.findIndex @constructor.groups, (group) => actorClass in group.npcMembers()
          startingPositions[actorClass.id()] = @constructor.answerLandmarks[groupIndex]

        for agent in @otherAgents()
          group = LOI.Adventure.Thing.getClassForId agent.studyGroupMembership.groupId
          groupIndex = @constructor.groups.indexOf group
          startingPositions[agent._id] = @constructor.answerLandmarks[groupIndex]

        group = LOI.Adventure.Thing.getClassForId C1.readOnlyState 'studyGroupId'
        groupIndex = @constructor.groups.indexOf group
        startingPositions[LOI.characterId()] = @constructor.answerLandmarks[groupIndex]

        if eventPhase is C1.Mixer.GalleryWest.EventPhases.CoordinatorIntro
          # Position coordinators.
          startingPositions[HQ.Actors.Shelley.id()] = 'MixerMiddle'
          startingPositions[HQ.Actors.Reuben.id()] = 'MixerRight'
          startingPositions[HQ.Actors.Alexandra.id()] = 'MixerLeft'

      else
        # Position students randomly.
        for actorClass in @constructor.actorClasses
          startingPositions[actorClass.id()] = 'GalleryFloor'

        for agent in @otherAgents()
          startingPositions[agent._id] = 'GalleryFloor'

      LOI.adventure.director.setPosition startingPositions
      LOI.adventure.director.facePosition startingFacingPositions

      unless eventPhase is C1.Mixer.GalleryWest.EventPhases.Answering
        # Make actors face random directions.
        for actorClass in @constructor.actorClasses
          actor = LOI.adventure.getCurrentThing actorClass

          direction = new THREE.Vector3 Math.random() * 2 - 1, 0, Math.random() * 2 - 1
          direction.normalize()
          actor.avatar.getRenderObject().faceDirection direction

    # Retro should talk when at location.
    @_eventIntroAutorun = @autorun (computation) =>
      return unless @listeners[0].scriptsReady()
      return unless retro = LOI.adventure.getCurrentThing HQ.Actors.Retro
      return unless retro.ready()

      if C1.Mixer.Intercom.state 'announcementDone'
        # The player has heard the announcement so Retro needs to welcome them.
        script.setThings {retro}
        label = 'RetroIntro'

      else
        # The announcement hasn't been played which means the player was in the gallery when the section started.
        return unless shelley = LOI.adventure.getCurrentThing HQ.Actors.Shelley
        return unless shelley.ready()
        script.setThings {retro, shelley}
        label = 'GalleryIntro'

      computation.stop()
      LOI.adventure.director.startScript script, {label}

    # Player should be in the mixer context.
    @_enterContextAutorun = @autorun (computation) =>
      # Don't overwrite an existing context.
      return if LOI.adventure.currentContext()

      LOI.adventure.enterContext C1.Mixer.Context

    @_autoStartScriptAutorun = @autorun (computation) =>
      # Make sure we're in the mixer context.
      return unless LOI.adventure.currentContext() instanceof C1.Mixer.Context

      # Autostart script interactions after the player has a name tag.
      return unless LOI.adventure.getCurrentInventoryThing C1.Mixer.NameTag
      return unless shelley = LOI.adventure.getCurrentThing HQ.Actors.Shelley
      return unless shelley.ready()

      # Wait until the location mesh has loaded, so that we have landmark positions.
      return unless LOI.adventure.world.sceneManager().currentLocationMeshData()

      computation.stop()

      Tracker.nonreactive =>
        unless script.state 'IceBreakersDone'
          # Start the mixer script at the latest checkpoint.
          script.startAtLatestCheckpoint [
            'MixerStart'
            'IceBreakersStart'
            'HobbyProfessionWriteStart'
            'PixelArtOtherStylesStart'
            'ExtrovertIntrovertStart'
            'IndividualTeamStart'
            'ComputersConsolesStart'
          ]

        if eventPhase is C1.Mixer.GalleryWest.EventPhases.JoinGroup
          script.startAtLatestCheckpoint [
            'JoinStudyGroupStart'
            'JoinStudyGroupContinue'
          ]

        if eventPhase is C1.Mixer.GalleryWest.EventPhases.CoordinatorIntro
          LOI.adventure.director.startScript script, label: 'CoordinatorIntro'

    # Script should continue when break time has passed.
    if eventPhase is C1.Mixer.GalleryWest.EventPhases.TalkToClassmates
      @_continueAfterBreakAutorun = @autorun (computation) =>
        # Wait until time left can be determined.
        return unless @talkToClassmatesMinutesLeft()?

        @scheduleTalkToClassmatesEnd()
        computation.stop()

    # Script needs group info after the join group section.
    if eventPhase is C1.Mixer.GalleryWest.EventPhases.JoinGroup
      C1.prepareGroupInfoInScript script

  onDeactivated: ->
    super arguments...

    @_positionActorsAutorun?.stop()
    @_eventIntroAutorun?.stop()
    @_enterContextAutorun?.stop()
    @_continueAfterBreakAutorun?.stop()
    @_autoStartScriptAutorun?.stop()
    @_agentActionsSubscriptionsAutorun?.stop()

    @_studyGroupMembershipSubscription?.stop()

    @cleanTalkToClassmatesEnd()
