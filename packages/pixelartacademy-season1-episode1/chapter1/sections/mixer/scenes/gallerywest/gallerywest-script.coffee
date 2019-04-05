LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends C1.Mixer.GalleryWest
  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      retro: HQ.Actors.Retro
      alexandra: HQ.Actors.Alexandra
      shelley: HQ.Actors.Shelley
      reuben: HQ.Actors.Reuben

    @setCallbacks
      MixerStart: (complete) =>
        # Students move into audience position.
        scene._moveStudentsToAudience()
        complete()
      
      IceBreakersStart: (complete) =>
        # Animate students to the middle.
        scene._moveStudentsToLandmark 'MixerMiddle'
        complete()

      HobbyProfessionStart: (complete) =>
        scene._animateOtherStudentsOnQuestion C1.Mixer.IceBreakers.Questions.HobbyProfession
        complete()

      HobbyProfessionEnd: (complete) =>
        answers = @state 'answers'
        scene._doAnswerAction C1.Mixer.IceBreakers.Questions.HobbyProfession, answers[0]
        complete()

      PixelArtOtherStylesStart: (complete) =>
        scene._animateOtherStudentsOnQuestion C1.Mixer.IceBreakers.Questions.PixelArtOtherStyles
        complete()

      PixelArtOtherStylesEnd: (complete) =>
        answers = @state 'answers'
        scene._doAnswerAction C1.Mixer.IceBreakers.Questions.PixelArtOtherStyles, answers[1]
        complete()

      ExtrovertIntrovertStart: (complete) =>
        scene._animateOtherStudentsOnQuestion C1.Mixer.IceBreakers.Questions.ExtrovertIntrovert
        complete()

      ExtrovertIntrovertEnd: (complete) =>
        answers = @state 'answers'

        personalityChanged = scene._changePersonality 1, 1 - answers[2]
        @ephemeralState 'factor1Changed', personalityChanged

        scene._doAnswerAction C1.Mixer.IceBreakers.Questions.ExtrovertIntrovert, answers[2]
        complete()

      IndividualTeamStart: (complete) =>
        scene._animateOtherStudentsOnQuestion C1.Mixer.IceBreakers.Questions.IndividualTeam
        complete()

      IndividualTeamEnd: (complete) =>
        answers = @state 'answers'

        personalityChanged = scene._changePersonality 2, answers[3] - 1
        @ephemeralState 'factor2Changed', personalityChanged

        scene._doAnswerAction C1.Mixer.IceBreakers.Questions.IndividualTeam, answers[3]
        complete()

      StartTalkToClassmates: (complete) =>
        scene.state 'talkToClassmatesStart', Date.now()

        # Wait for state to be propagated.
        Tracker.afterFlush =>
          scene.scheduleTalkToClassmatesEnd()
          complete()

      JoinStudyGroupStart: (complete) =>
        # Students form the audience around Shelley.
        scene._moveStudentsToAudience()
        complete()

      JoinStudyGroupMovement: (complete) =>
        # Students go to their group.
        moveStudent = (student, groupIndex) =>
          # Start movement after some deliberation.
          Meteor.setTimeout =>
            landmark = scene.constructor.answerLandmarks[groupIndex]
            scene._movePersonToLandmark student, landmark, faceLandmark: landmark
          ,
            Math.random() * 5000

        for actor in scene.actors()
          groupIndex = _.findIndex scene.constructor.groups, (group) => actor.constructor in group.npcMembers()
          moveStudent actor, groupIndex

        for agent in scene.otherAgents()
          group = LOI.Adventure.Thing.getClassForId agent.studyGroupMembership.groupId
          groupIndex = scene.constructor.groups.indexOf group
          moveStudent agent, groupIndex

        complete()

      JoinStudyGroupMakeChoice: (complete) =>
        # Read which group the player chose.
        groupIndex = @state 'groupChoice'

        # Mark membership in the group.
        group = scene.constructor.groups[groupIndex]
        C1.Mixer.GalleryWest.joinGroup LOI.characterId(), group.id()

        # Move character to his group.
        landmark = scene.constructor.answerLandmarks[groupIndex]

        # Temporarily add just group letter information.
        studyGroup = letter: _.last group.id()
        @ephemeralState 'studyGroup', studyGroup

        scene._movePersonToLandmark LOI.character(), landmark,
          faceLandmark: landmark
          onCompleted: =>
            complete()

      JoinStudyGroupContinue: (complete) =>
        # Everyone looks at Shelly.
        scene._faceStudentsToLandmark 'InFrontOfProjector'
        complete()

      JoinStudyGroupAlexandra: (complete) =>
        alexandra = LOI.adventure.getCurrentThing HQ.Actors.Alexandra
        scene._movePersonToLandmark alexandra, 'MixerLeft'
        complete()

      JoinStudyGroupReuben: (complete) =>
        reuben = LOI.adventure.getCurrentThing HQ.Actors.Reuben
        scene._movePersonToLandmark reuben, 'MixerRight'
        complete()

      JoinStudyGroupShelley: (complete) =>
        shelley = LOI.adventure.getCurrentThing HQ.Actors.Shelley
        scene._movePersonToLandmark shelley, 'MixerMiddle',
          onCompleted: =>
            complete()

      CoordinatorIntro: (complete) =>
        C1.prepareGroupInfoInScript @
        # Make coordinators face the students.
        LOI.adventure.director.facePosition
          "#{HQ.Actors.Shelley.id()}": 'MixerMiddle'
          "#{HQ.Actors.Reuben.id()}": 'MixerRight'
          "#{HQ.Actors.Alexandra.id()}": 'MixerLeft'

        complete()

      CoordinatorAddressStart: (complete) =>
        # Make students face the coordinators.
        facingPositions = {}

        for actorClass in scene.constructor.actorClasses
          group = _.find scene.constructor.groups, (group) => actorClass in group.npcMembers()
          facingPositions[actorClass.id()] = group.coordinator().id()

        for agent in scene.otherAgents()
          group = LOI.Adventure.Thing.getClassForId agent.studyGroupMembership.groupId
          facingPositions[agent._id] = group.coordinator().id()

        characterStudyGroupId = C1.readOnlyState 'studyGroupId'
        characterStudyGroup = LOI.Adventure.Thing.getClassForId characterStudyGroupId
        facingPositions[LOI.characterId()] = characterStudyGroup.coordinator().id()

        LOI.adventure.director.facePosition facingPositions
          
        complete()

      MixerEnd: (complete) =>
        # Exit the mixer context.
        LOI.adventure.exitContext()
        complete()
