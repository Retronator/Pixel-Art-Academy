AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Student.Conversation extends LOI.Adventure.Scene.ConversationBranch
  @id: -> 'PixelArtAcademy.Student.Conversation'

  @location: ->
    # Applies to all locations, but has filtering to match students.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy/student/conversation/conversation.script'
  @returnLabel: -> 'MainQuestions'

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

    # Transfer ephemeral state for the groupmate from main to this script.
    ephemeralPersons = script._mainScript.ephemeralState 'persons'
    ephemeralStudent = ephemeralPersons[student._id]
    script.ephemeralState 'student', ephemeralStudent

    journals = PAA.Practice.Journal.documents.fetch
      'character._id': student._id
    ,
      sort:
        order: 1

    _.extend ephemeralStudent,
      journalIds: (journal._id for journal in journals)

    # Prepare student's and character's profile.
    studentProfile = @prepareProfile student.instance.document().profile
    script.ephemeralState 'studentProfile', studentProfile

    profile = @prepareProfile LOI.character().document().profile
    script.ephemeralState 'profile', profile

  prepareProfile: (profile) ->
    profile = _.cloneDeep profile or {}

    if profile.country
      # Insert translated country name.
      countryTranslation = AB.existingTranslation 'Artificial.Babel.Region.Names', profile.country
      profile.country = countryTranslation.translate()?.text

    if profile.aspiration
      # Replace any newline characters with spaces.
      profile.aspiration = profile.aspiration.replace /\n/g, ' '

    profile

  # Script

  initializeScript: ->
    super arguments...

    @setCallbacks
      Journal: (complete) =>
        complete()

        student = @ephemeralState 'student'
        journalId = student.journalIds[0]

        # Create the journal view context and enter it.
        context = new PAA.PixelBoy.Apps.Journal.JournalView.Context {journalId}
        LOI.adventure.enterContext context

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    super arguments...

    scene = @options.parent

    return unless choicePlaceholderResponse.placeholderId is 'PersonConversationMainQuestions'

    # This choices only apply to students.
    person = choicePlaceholderResponse.script.things.person
    return unless person.is PAA.Student
    student = person

    # Save the script so we can access its ephemeral state.
    @script._mainScript = choicePlaceholderResponse.script

    choicePlaceholderResponse.addChoices @script.startNode.labels.MainQuestions.next

    # Prepare script for talking about this student.
    Tracker.nonreactive => scene.prepareScriptForStudent student
