LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Student.Conversation extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Student.Conversation'

  @location: ->
    # Applies to all locations, but has filtering to match students.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy/student/conversation/conversation.script'

  constructor: ->
    super arguments...

    # Subscribe to students' journals.
    @_journalsSubscriptionAutorun = Tracker.autorun =>
      return unless LOI.adventureInitialized()
      otherAgents = LOI.adventure.currentOtherAgents()
      characterIds = (agent._id for agent in otherAgents)

      PAA.Practice.Journal.forCharacterIds.subscribe characterIds

  destroy: ->
    super arguments...

    @_journalsSubscriptionAutorun.stop()

  prepareScriptForStudent: (student) ->
    script = @listeners[0].script

    # Replace the student with target character.
    script.setThings {student}

    # Prepare an ephemeral object for this student (we need it to be unique for the current student).
    ephemeralStudents = script.ephemeralState('students') or {}
    ephemeralStudents[student._id] ?= {}
    ephemeralStudent = ephemeralStudents[student._id]

    journals = PAA.Practice.Journal.documents.fetch
      'character._id': student._id
    ,
      sort:
        order: 1

    _.extend ephemeralStudent,
      journalIds: (journal._id for journal in journals)

    script.ephemeralState 'students', ephemeralStudents
    script.ephemeralState 'student', ephemeralStudent

  # Script

  initializeScript: ->
    @setCallbacks
      Return: (complete) =>
        # Return back to main questions of the calling script.
        LOI.adventure.director.startScript @_returnScript, label: 'MainQuestions'
        complete()

      Journal: (complete) =>
        complete()

        student = @ephemeralState 'student'
        journalId = student.journalIds[0]

        # Create the journal view context and enter it.
        context = new PAA.PixelBoy.Apps.Journal.JournalView.Context {journalId}
        LOI.adventure.enterContext context

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    scene = @options.parent

    return unless choicePlaceholderResponse.placeholderId is 'PersonConversationMainQuestions'

    # This choices only apply to students.
    person = choicePlaceholderResponse.script.things.person
    return unless person.is PAA.Student

    # Save the student to our script.
    student = person
    @script.setThings {student}

    # Save the script so we know where to return to.
    @script._returnScript = choicePlaceholderResponse.script

    choicePlaceholderResponse.addChoices @script.startNode.labels.MainQuestions.next

    # Prepare script for talking about this student.
    Tracker.nonreactive => scene.prepareScriptForStudent student
