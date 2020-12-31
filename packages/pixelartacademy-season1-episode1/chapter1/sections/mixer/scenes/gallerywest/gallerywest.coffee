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

  @translations: ->
    # We provide intro through translations, not @intro, since we provide a custom binding for it.
    intro: """
      You enter a big gallery space that is holding a gathering.
      You recognize some people from the HQ, others seem to be visitors like yourself.
    """

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/mixer/scenes/gallerywest/gallerywest.script'

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
  
  # Subscriptions
  
  @latestStudyGroupMembers = new AB.Subscription
    name: "#{@id()}.latestStudyGroupMembers"
    query: =>
      membershipIds = []

      for group in @groups
        memberships = LOI.Character.Membership.documents.fetch
          groupId: group.id()
          'character._id': $ne: LOI.characterId()
        ,
          sort:
            joinTime: -1
          limit: 2

        for membership in memberships
          membershipIds.push membership._id

      LOI.Character.Membership.documents.find
        _id: $in: membershipIds

  otherAgents: ->
    # Two latest agents from each study group should be present at the mixer.
    for membership in @constructor.latestStudyGroupMembers.query().fetch()
      # Also attach the membership information to the agent.
      agent = LOI.Character.getAgent membership.character._id
      agent.studyGroupMembership = membership
      agent
      
  agents: -> [LOI.agent(), @otherAgents()...]
  actors: ->
    actors = (LOI.adventure.getCurrentThing actorClass for actorClass in @constructor.actorClasses)
    _.without actors, null, undefined

  students: -> [@agents()..., @actors()...]
  otherStudents: -> [@otherAgents()..., @actors()...]

  things: ->
    _.flatten [
      HQ.Actors.Shelley
      @constructor.Retro
      HQ.Actors.Alexandra
      HQ.Actors.Reuben
      @constructor.actorClasses
      @otherAgents()
      C1.Mixer.Table
      C1.Mixer.Marker
      C1.Mixer.Stickers
    ]

  eventPhase: ->
    script = @listeners[0].script

    return C1.Mixer.GalleryWest.EventPhases.CoordinatorIntro if script.state 'CoordinatorIntro'
    return C1.Mixer.GalleryWest.EventPhases.JoinGroup if script.state 'JoinStudyGroupStart'
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

  _animateOtherStudentsOnQuestion: (question) ->
    for student in @otherStudents()
      # Find which answer the student chose.
      action = student.getActions(
        type: C1.Mixer.IceBreakers.AnswerAction.type
        'content.question': question
      )[0]

      # Go to the landmark that corresponds to the answer, after some deliberation.
      do (student, action) =>
        Meteor.setTimeout =>
          @_movePersonToAnswerLandmark student, action.content.answer
        ,
          Math.random() * 5000

  _movePersonToAnswerLandmark: (person, answer) ->
    @_movePersonToLandmark person, @constructor.answerLandmarks[answer]

  _doAnswerAction: (question, answer) ->
    type = C1.Mixer.IceBreakers.AnswerAction.type
    situation = LOI.adventure.currentSituationParameters()
    character = LOI.character()
    LOI.Memory.Action.do type, character._id, situation, {question, answer}

    # Move the character to the landmark.
    @_movePersonToAnswerLandmark character, answer
