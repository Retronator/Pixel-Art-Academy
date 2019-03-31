AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest.Student extends LOI.Adventure.Listener
  @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.GalleryWest.Student"

  @scriptUrls: -> [
    'retronator_pixelartacademy-season1-episode1/chapter1/sections/mixer/scenes/gallerywest/student/student.script'
  ]

  @avatars: ->
    answer: C1.Mixer.Answer
    answers: C1.Mixer.Answers
    nameTag: C1.Mixer.NameTag
    sticker: C1.Mixer.Sticker
    stickers: C1.Mixer.Stickers

  class @Script extends LOI.Adventure.Script
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.GalleryWest.Student'
    @initialize()

    initialize: ->
      # Initialize script.

    prepareForStudent: (student) ->
      # Replace the student with target character.
      @setThings {student}

      studentId = student._id or student.id()

      # Prepare an ephemeral object for this student (we need it to be unique for the current student).
      ephemeralStudents = @ephemeralState('students') or {}
      ephemeralStudents[studentId] ?= {}
      ephemeralStudent = ephemeralStudents[studentId]

      @ephemeralState 'students', ephemeralStudents
      @ephemeralState 'student', ephemeralStudent
      
      profile = @options.listener.prepareProfile student.instance.document().profile
      @ephemeralState 'studentProfile', profile
  
      answers = @options.listener.prepareAnswers student
      @ephemeralState 'studentAnswers', answers

  @initialize()

  onEnter: (enterResponse) ->
    # Subscribe to all regions and the translations of their names.
    @_regionNamesSubscription ?= AB.Translation.forNamespace.subscribe 'Artificial.Babel.Region.Names'

  cleanup: ->
    super arguments...

    @_regionNamesSubscription?.stop()
    @_regionNamesSubscription = null
    
  prepareProfile: (profile) ->
    profile = _.cloneDeep profile or {}
    
    if profile.country
      # Insert translated country name.
      countryTranslation = AB.Translation.documents.findOne(namespace: 'Artificial.Babel.Region.Names', key: profile.country)
      profile.country = countryTranslation.translate(AB.languagePreference())?.text

    if profile.aspiration
      # Replace any newline characters with spaces.
      profile.aspiration = profile.aspiration.replace /\n/g, ' '
      
    profile

  prepareAnswers: (student) ->
    answers = {}

    for question of C1.Mixer.IceBreakers.Questions
      answers[question] = student.getActions(
        type: C1.Mixer.IceBreakers.AnswerAction.type
        'content.question': question
      )[0].content.answer

    answers

  onScriptsLoaded: ->
    @script = @scripts[@id()]

  onCommand: (commandResponse) ->
    scene = @options.parent
    return unless scene.eventPhase() is C1.Mixer.GalleryWest.EventPhases.TalkToClassmates

    # You should be able to talk to all PC and NPC students.
    for actorClass in scene.constructor.actorClasses
      do (actorClass) =>
        actor = LOI.adventure.getCurrentThing actorClass

        prepareScriptForStudent = =>
          profile = @prepareProfile LOI.character().document().profile
          @script.ephemeralState 'profile', profile

          @script.prepareForStudent actor

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.TalkTo, actor]
          action: =>
            # Prepare character variables.
            prepareScriptForStudent()
            LOI.adventure.director.startScript @script

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.LookAt, actor]
          priority: 1
          action: =>
            prepareScriptForStudent()
            LOI.adventure.director.startNode new NarrativeNode line: actor.description()
            LOI.adventure.director.startScript @script, label: 'LookAtStudent'

        lookAtAnswersAction = =>
          prepareScriptForStudent()
          LOI.adventure.director.startScript @script, label: 'LookAtAnswers'

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.LookAt, possessive: actor, [@avatars.answers, @avatars.answer]]
          action: lookAtAnswersAction

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.LookAt, possessive: actor, [@avatars.stickers, @avatars.sticker]]
          action: lookAtAnswersAction

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.LookAt, possessive: actor, @avatars.nameTag]
          action: =>
            prepareScriptForStudent()
            LOI.adventure.director.startScript @script, label: 'LookAtNameTag'
