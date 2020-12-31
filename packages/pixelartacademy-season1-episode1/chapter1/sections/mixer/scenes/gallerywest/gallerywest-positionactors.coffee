LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends C1.Mixer.GalleryWest
  _positionActors: ->
    script = @listeners[0].script
    eventPhase = @eventPhase()

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

      unless question?
        console.warn "Invalid script state. We are in the Answering state, but no answers-written labels have been reached."
        return

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

  _movePersonToLandmark: (person, landmark, options = {}) ->
    options.faceLandmark ?= 'InFrontOfProjector'

    person.avatar.walkTo
      target: landmark
      onCompleted: =>
        person.avatar.lookAt options.faceLandmark

        options.onCompleted?()

  _moveStudentsToLandmark: (landmark) ->
    for student in @students()
      @_movePersonToLandmark student, landmark

  _faceStudentsToLandmark: (landmark) ->
    for student in @students()
      renderObject = student.avatar.getRenderObject()
      renderObject.facePosition landmark

  _moveStudentsToAudience: ->
    for student in @students()
      renderObject = student.avatar.getRenderObject()
      center = LOI.adventure.world.getPositionVector 'InFrontOfProjector'
      relativePositionToCenter = new THREE.Vector3().subVectors renderObject.position, center
      angle = Math.atan2 relativePositionToCenter.x, relativePositionToCenter.z
      distance = relativePositionToCenter.length()

      # Move student to audience position.
      maxAngle = 1
      distanceNear = 3.5
      distanceFar = 5

      angle = _.clamp(angle, -maxAngle / 2, maxAngle / 2) + Math.random() * maxAngle / 2 unless -maxAngle < angle < maxAngle
      distance = distanceNear + Math.random() * (distanceFar - distanceNear) unless distanceNear < distance < distanceFar
      relativePositionToCenter.x = Math.sin(angle) * distance
      relativePositionToCenter.z = Math.cos(angle) * distance
      targetPosition = new THREE.Vector3().addVectors center, relativePositionToCenter

      @_movePersonToLandmark student, targetPosition

  _spreadStudentsAroundGallery: ->
    for student in @students()
      student.avatar.walkTo target: 'GalleryFloor'
