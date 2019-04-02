AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.GalleryWest'

  @location: ->
    HQ.GalleryWest

  @intro: -> """
    You enter a big gallery space that is holding a gathering.
    You recognize some people from the HQ, others seem to be visitors like yourself.
  """

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/mixer/scenes/gallerywest/gallerywest.script'

  @listeners: -> [
    @Listener
    @Student
  ]

  # Note: Initialized is called in the extended class.

  @actorClasses = [
    PAA.Actors.Ace
    PAA.Actors.Ty
    PAA.Actors.Saanvi
    PAA.Actors.Mae
    PAA.Actors.Lisa
    PAA.Actors.Jaxx
  ]

  @answerLandmarks = [
    'MixerLeft'
    'MixerMiddle'
    'MixerRight'
  ]
  
  @groups = [
    C1.Groups.AdmissionsStudyGroup.A
    C1.Groups.AdmissionsStudyGroup.B
    C1.Groups.AdmissionsStudyGroup.C
  ]

  @EventPhases =
    BeforeStart: 'BeforeStart'
    Intro: 'Intro'
    Answering: 'Answering'
    TalkToClassmates: 'TalkToClassmates'
    JoinGroup: 'JoinGroup'
    CoordinatorIntro: 'CoordinatorIntro'

  # Methods

  @joinGroup: new AB.Method name: "#{@id()}.joinGroup"
    
  things: -> _.flatten [
    HQ.Actors.Shelley
    @constructor.Retro
    HQ.Actors.Alexandra
    HQ.Actors.Reuben
    @constructor.actorClasses
    C1.Mixer.Table
    C1.Mixer.Marker
    C1.Mixer.Stickers
  ]

  eventPhase: ->
    script = @listeners[0].script

    return C1.Mixer.GalleryWest.EventPhases.CoordinatorIntro if script.state 'CoordinatorIntro'
    return C1.Mixer.GalleryWest.EventPhases.JoinGroup if script.state 'JoinStudyGroupIntro'
    return C1.Mixer.GalleryWest.EventPhases.TalkToClassmates if script.state 'IceBreakersDone'
    return C1.Mixer.GalleryWest.EventPhases.Answering if script.state 'HobbyProfessionContinue'
    return C1.Mixer.GalleryWest.EventPhases.Intro if script.state 'MixerStart'
    C1.Mixer.GalleryWest.EventPhases.BeforeStart

  # The time, in minutes, until the break for talking to classmates ends.
  talkToClassmatesMinutesLeft: ->
    return unless talkToClassmatesStart = @state 'talkToClassmatesStart'
    elapsedMilliseconds = Date.now() - talkToClassmatesStart
    elapsedMinutes = elapsedMilliseconds / 1000 / 60

    5 - elapsedMinutes

  scheduleTalkToClassmatesEnd: ->
    millisecondsLeft = Math.max 0, @talkToClassmatesMinutesLeft() * 60 * 1000
    
    @_talkToClassmatesEndTimeout = Meteor.setTimeout =>
      LOI.adventure.director.startScript @listeners[0].script, label: 'JoinStudyGroupIntro'
    ,
      millisecondsLeft
    
  cleanTalkToClassmatesEnd: ->
    Meteor.clearTimeout @_talkToClassmatesEndTimeout
    
  prepareGroupInfoInScript: ->
    return unless studyGroupId = C1.readOnlyState 'studyGroupId'
    group = LOI.Adventure.Thing.getClassForId studyGroupId

    letter = _.last studyGroupId
    location = if letter is 'C' then group.location().longName() else group.location().shortName()
    studyGroup = {letter, location}

    script = @listeners[0].script
    script.ephemeralState 'studyGroup', studyGroup
    
    script.setCurrentThings
      coordinator: group.coordinator()

  _animateActorsOnQuestion: (question) ->
    for actorClass in @constructor.actorClasses
      actor = LOI.adventure.getCurrentThing actorClass

      # Find which answer the actor chose.
      action = actor.getActions(
        type: C1.Mixer.IceBreakers.AnswerAction.type
        'content.question': question
      )[0]

      # Go to the landmark that corresponds to the answer.
      @_movePersonToAnswerLandmark actor, action.content.answer

  _movePersonToAnswerLandmark: (person, answer) ->
    @_movePersonToLandmark person, @constructor.answerLandmarks[answer]

  _movePersonToLandmark: (person, landmark, options = {}) ->
    options.faceLandmark ?= 'InFrontOfProjector'

    renderObject = person.avatar.getRenderObject()
    renderObject.setAnimation 'Walk'

    LOI.adventure.world.navigator().moveAvatar
      avatar: person.avatar
      target: landmark
      speed: 1.25
      onCompleted: =>
        renderObject.setAnimation 'Idle'
        renderObject.facePosition options.faceLandmark

        options.onCompleted?()

  _doAnswerAction: (question, answer) ->
    type = C1.Mixer.IceBreakers.AnswerAction.type
    situation = LOI.adventure.currentSituationParameters()
    character = LOI.character()
    LOI.Memory.Action.do type, character._id, situation, {question, answer}

    # Move the character to the landmark.
    @_movePersonToAnswerLandmark character, answer

  _moveStudentsToLandmark: (landmark) ->
    for student in @_getStudents()
      @_movePersonToLandmark student, landmark

  _faceStudentsToLandmark: (landmark) ->
    for student in @_getStudents()
      renderObject = student.avatar.getRenderObject()
      renderObject.facePosition landmark

  _moveStudentsToAudience: ->
    for student in @_getStudents()
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

  _getStudents: ->
    _.flatten [
      LOI.character()
      LOI.adventure.getCurrentThing actorClass for actorClass in @constructor.actorClasses
    ]
