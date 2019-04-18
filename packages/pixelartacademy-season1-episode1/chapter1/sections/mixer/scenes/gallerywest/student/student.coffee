AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class C1.Mixer.GalleryWest.Student extends LOI.Adventure.Scene.PersonConversation
  @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.GalleryWest.Student"

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/mixer/scenes/gallerywest/student/student.script'

  @avatars: ->
    answer: C1.Mixer.Answer
    answers: C1.Mixer.Answers
    nameTag: C1.Mixer.NameTag
    sticker: C1.Mixer.Sticker
    stickers: C1.Mixer.Stickers

  prepareForStudent: (student) ->
    # Replace the student with target character.
    @setThings {student}

    answers = @options.listener.prepareAnswers student
    @ephemeralState 'studentAnswers', answers

  @initialize()

  prepareAnswers: (student) ->
    answers = {}

    for question of C1.Mixer.IceBreakers.Questions
      answers[question] = student.getActions(
        type: C1.Mixer.IceBreakers.AnswerAction.type
        'content.question': question
      )[0].content.answer

    answers

  onCommand: (commandResponse) ->
    scene = @options.parent
    return unless scene.eventPhase() is C1.Mixer.GalleryWest.EventPhases.TalkToClassmates

    # You should be able to talk to all PC and NPC students.
    for student in scene.otherStudents()
      do (student) =>
        prepareScriptForStudent = =>
          profile = @prepareProfile LOI.character().document().profile
          @script.ephemeralState 'profile', profile

          @script.prepareForStudent student

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.TalkTo, student]
          priority: 1
          action: =>
            # Prepare character variables.
            prepareScriptForStudent()
            LOI.adventure.director.startScript @script

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.LookAt, student]
          priority: 1
          action: =>
            prepareScriptForStudent()
            LOI.adventure.director.startNode new Nodes.NarrativeLine line: student.description()
            LOI.adventure.director.startScript @script, label: 'LookAtStudent'

        lookAtAnswersAction = =>
          prepareScriptForStudent()
          LOI.adventure.director.startScript @script, label: 'LookAtAnswers'

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.LookAt, possessive: student, [@avatars.answers, @avatars.answer]]
          action: lookAtAnswersAction

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.LookAt, possessive: student, [@avatars.stickers, @avatars.sticker]]
          action: lookAtAnswersAction

        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.LookAt, possessive: student, @avatars.nameTag]
          action: =>
            prepareScriptForStudent()
            LOI.adventure.director.startScript @script, label: 'LookAtNameTag'
