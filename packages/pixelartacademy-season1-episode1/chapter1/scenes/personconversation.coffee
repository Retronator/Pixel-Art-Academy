LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ
SF = SanFrancisco

Vocabulary = LOI.Parser.Vocabulary

class C1.PersonConversation extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PersonConversation'

  @location: ->
    # Applies to all locations.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/scenes/personconversation.script'

  constructor: ->
    super

    # Subscribe to everyone's journals.
    @_journalSubscriptions = Tracker.autorun =>
      people = _.filter LOI.adventure.currentLocationThings(), (thing) => thing instanceof LOI.Character.Person
      characterIds = (person._id for person in people)

      PAA.Practice.Journal.forCharacterIds.subscribe characterIds

  destroy: ->
    super

    @_journalSubscriptions.stop()
    
  # Script

  initializeScript: ->
    @setCallbacks
      HangOut: (complete) =>
        # Add person we're talking to as a member to the SF friends group.
        person = @ephemeralState 'person'
        memberId = person._id

        LOI.Character.Group.addMember LOI.characterId(), C1.Groups.SanFranciscoFriends.id(), memberId

        complete()

      Journal: (complete) =>
        complete()

        person = @ephemeralState 'person'
        journalId = person.journalIds[0]

        # Create the journal view context and enter it.
        context = new PAA.PixelBoy.Apps.Journal.JournalView.Context {journalId}
        LOI.adventure.enterContext context

  # Listener

  onCommand: (commandResponse) ->
    people = _.filter LOI.adventure.currentLocationThings(), (thing) => thing instanceof LOI.Character.Person
    characterId = LOI.characterId()

    for person in people when person._id isnt characterId
      do (person) =>
        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.TalkTo, person.avatar]
          action: =>
            # Replace the person with target character.
            @script.setThings {person}

            # Prepare a permanent state object for this person.
            peopleState = @script.state('people') or {}
            peopleState[person._id] ?= {}

            personState = peopleState[person._id]

            @script.state 'people', peopleState
            @script.state 'person', personState

            # Prepare an ephemeral object for this person.
            ephemeralPeople = @script.ephemeralState('people') or {}
            ephemeralPeople[person._id] ?= {}

            ephemeralPerson = ephemeralPeople[person._id]

            journals = PAA.Practice.Journal.documents.fetch
              'character._id': person._id
            ,
              sort:
                order: 1

            _.extend ephemeralPerson,
              _id: person._id
              inGroup: C1.Groups.SanFranciscoFriends.isCharacterMember person._id
              name: person.fullName()
              journalIds: (journal._id for journal in journals)

            @script.ephemeralState 'people', ephemeralPeople
            @script.ephemeralState 'person', ephemeralPerson

            @startScript()
