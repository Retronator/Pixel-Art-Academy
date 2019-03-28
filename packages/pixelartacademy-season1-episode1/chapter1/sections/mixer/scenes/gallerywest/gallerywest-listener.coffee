LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends C1.Mixer.GalleryWest
  @initialize()

  @avatars: ->
    answer: C1.Mixer.Answer

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Determine event phase.
    eventPhase = scene.eventPhase()

    # Subscribe to agents' actions.
    @_agentActionsSubscription = C1.Mixer.IceBreakers.AnswerAction.latestAnswersForCharacter.subscribe LOI.characterId()

    @_positionActorsAutorun = @autorun (computation) =>
      # Wait until the location mesh has loaded, so that we have landmark positions.
      return unless LOI.adventure.world.sceneManager().currentLocationMeshData()

      # Wait until the agent actions have arrived.
      return unless @_agentActionsSubscription.ready()

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
        ]

        questions = [
          C1.Mixer.IceBreakers.Questions.HobbyProfession
          C1.Mixer.IceBreakers.Questions.PixelArtOtherStyles
          C1.Mixer.IceBreakers.Questions.ExtrovertIntrovert
        ]

        question = null

        for answerStart, index in answerStarts
          if @script.state answerStart
            question = questions[index]

          else
            break
            
        actors = (LOI.adventure.getCurrentThing actorClass for actorClass in C1.Mixer.GalleryWest.actorClasses)
        agents = (LOI.Character.getAgent characterId for characterId in [LOI.characterId()])
        
        for person in [actors..., agents...]
          # Find which answer the actor chose.
          action = person.getActions(
            type: C1.Mixer.IceBreakers.AnswerAction.type
            'content.question': question
          )[0]

          # Get either the agent's character ID or actor's thing ID.
          personId = person._id or person.id()

          startingPositions[personId] = C1.Mixer.GalleryWest.answerLandmarks[action.content.answer]
          startingFacingPositions[personId] = 'InFrontOfProjector'

      else
        # Position students randomly.
        for actorClass in scene.constructor.actorClasses
          startingPositions[actorClass.id()] = 'GalleryFloor'

      LOI.adventure.director.setPosition startingPositions
      LOI.adventure.director.facePosition startingFacingPositions

      unless eventPhase is C1.Mixer.GalleryWest.EventPhases.Answering
        # Make actors face random directions.
        for actorClass in scene.constructor.actorClasses
          actor = LOI.adventure.getCurrentThing actorClass

          direction = new THREE.Vector3 Math.random() * 2 - 1, 0, Math.random() * 2 - 1
          direction.normalize()
          actor.avatar.getRenderObject().faceDirection direction

    # Retro should talk when at location.
    @_retroTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless retro = LOI.adventure.getCurrentThing HQ.Actors.Retro
      return unless retro.ready()
      computation.stop()

      @script.setThings {retro}

      @startScript label: 'RetroIntro'

    # Player should be in the mixer context when they have a name tag.
    @_enterContextAutorun = @autorun (computation) =>
      return if LOI.adventure.currentContext() instanceof C1.Mixer.Context
      return unless LOI.adventure.getCurrentInventoryThing C1.Mixer.NameTag
      return unless shelley = LOI.adventure.getCurrentThing HQ.Actors.Shelley
      return unless shelley.ready()

      LOI.adventure.enterContext C1.Mixer.Context

      unless @script.state 'IceBreakersDone'
        # Start the mixer script at the latest checkpoint.
        checkpoints = [
          'MixerStart'
          'IceBreakersStart'
          'HobbyProfessionWriteStart'
          'PixelArtOtherStylesStart'
          'ExtrovertIntrovertStart'
          'IndividualTeamStart'
        ]

        for checkpoint, index in checkpoints
          # Start at this checkpoint if we haven't reached the next one yet.
          nextCheckpoint = checkpoints[index + 1]

          unless nextCheckpoint and @script.state nextCheckpoint
            @startScript label: checkpoint
            return

  cleanup: ->
    @_positionActorsAutorun?.stop()
    @_retroTalksAutorun?.stop()
    @_enterContextAutorun?.stop()

    @_agentActionsSubscription?.stop()

  onCommand: (commandResponse) ->
    scene = @options.parent

    return unless alexandra = LOI.adventure.getCurrentThing HQ.Actors.Alexandra
    return unless retro = LOI.adventure.getCurrentThing HQ.Actors.Retro
    return unless shelley = LOI.adventure.getCurrentThing HQ.Actors.Shelley
    return unless reuben = LOI.adventure.getCurrentThing HQ.Actors.Reuben

    return unless marker = LOI.adventure.getCurrentThing C1.Mixer.Marker
    return unless stickers = LOI.adventure.getCurrentThing C1.Mixer.Stickers

    eventPhase = scene.eventPhase()

    if eventPhase is C1.Mixer.GalleryWest.EventPhases.BeforeStart
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, alexandra]
        action: => @startScript label: 'TalkToAlexandra'
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, retro]
        action: => @startScript label: 'TalkToRetro'
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, shelley]
        action: => @startScript label: 'TalkToShelley'
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, reuben]
        action: => @startScript label: 'TalkToReuben'
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Get, marker]
        action: =>
          marker.state 'inInventory', true
          true
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Get, stickers]
        action: =>
          stickers.state 'inInventory', true
          true

    if eventPhase is C1.Mixer.GalleryWest.EventPhases.Answering
      writeAnswerAction = =>
        firstAnswerIndex = @script.state('answers')[0]
        answers = ['Hobby', 'Hobby + Professional', 'Professional']

        @script.ephemeralState 'firstAnswer', answers[firstAnswerIndex]

        @startScript label: 'HobbyProfessionWrite'

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Use, marker]
        priority: 1
        action: writeAnswerAction

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Use, stickers]
        priority: 1
        action: writeAnswerAction

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.UseWith, marker, stickers]
        priority: 1
        action: writeAnswerAction

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Write, @avatars.answer]
        action: writeAnswerAction

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.WriteOn, @avatars.answer, stickers]
        action: writeAnswerAction

    if eventPhase is C1.Mixer.GalleryWest.EventPhases.TalkToClassmates
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, retro]
        action: =>
          @script.ephemeralState 'talkToClassmatesMinutesLeft', Math.round(scene.talkToClassmatesMinutesLeft())
          @startScript label: 'TalkToRetroDuringBreak'

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, alexandra]
        action: => @startScript label: 'TalkToAlexandraDuringBreak'

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, shelley]
        action: => @startScript label: 'TalkToShelleyDuringBreak'

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, reuben]
        action: => @startScript label: 'TalkToReubenDuringBreak'
