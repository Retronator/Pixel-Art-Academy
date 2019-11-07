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

    # Position actors based on event phase.
    @_positionActorsAutorun = @autorun (computation) =>
      # Wait until the location mesh has loaded, so that we have landmark positions.
      return unless LOI.adventure.world.sceneManager().currentLocationMeshData()

      # Wait until the agent actions have arrived.
      for subscription in @_agentActionsSubscriptions()
        return unless subscription.ready()

      computation.stop()
      @_positionActors()

    # Player should be in the mixer context.
    @_enterContextAutorun = @autorun (computation) =>
      # Don't overwrite an existing context.
      return if LOI.adventure.currentContext()

      LOI.adventure.enterContext C1.Mixer.Context

    # Intro with Retro (and Shelley) should play when at location.
    @_eventIntroAutorun = @autorun (computation) =>
      # Make sure we're in the mixer context. Otherwise the running scripts would get cleared on context switch.
      return unless LOI.adventure.currentContext() instanceof C1.Mixer.Context
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
