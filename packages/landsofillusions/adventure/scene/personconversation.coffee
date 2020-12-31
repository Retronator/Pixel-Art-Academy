LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Scene.PersonConversation extends LOI.Adventure.Scene
  @location: ->
    # Applies to all locations, but can have filtering to match only certain conditions.
    null

  startMainQuestionsWithPerson: (person) ->
    @prepareScriptForPerson person

    script = @listeners[0].script
    LOI.adventure.director.startScript script, label: 'MainQuestions'

  prepareScriptForPerson: (@currentPerson) ->
    script = @listeners[0].script

    # Replace the person with target character.
    script.setThings person: @currentPerson

    # Prepare an ephemeral object for this person (we need it to be unique for the current person).
    ephemeralPersons = script.ephemeralState('persons') or {}
    ephemeralPersons[@currentPerson._id] ?= {}
    ephemeralPerson = ephemeralPersons[@currentPerson._id]

    script.ephemeralState 'persons', ephemeralPersons
    script.ephemeralState 'person', ephemeralPerson
