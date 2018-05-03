LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ
SF = SanFrancisco

Vocabulary = LOI.Parser.Vocabulary

class C1.SanFranciscoConversation extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.SanFranciscoConversation'

  @location: ->
    # Applies to all locations, but has filtering to match only SF regions.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/scenes/sanfranciscoconversation.script'

  startMainQuestionsWithPerson: (person) ->
    @_prepareScriptForPerson person

    script = @listeners[0].script
    LOI.adventure.director.startScript script, label: 'MainQuestions'

  _prepareScriptForPerson: (person) ->
    script = @listeners[0].script

    # Replace the person with target character.
    script.setThings {person}

    # Prepare an ephemeral object for this person (we need it to be unique for the current person).
    ephemeralPeople = script.ephemeralState('people') or {}
    ephemeralPeople[person._id] ?= {}
    ephemeralPerson = ephemeralPeople[person._id]

    script.ephemeralState 'people', ephemeralPeople
    script.ephemeralState 'person', ephemeralPerson

  # Listener

  onCommand: (commandResponse) ->
    # This conversation only applies to SF regions.
    regions = [
      SF.Soma
      SF.C3
      HQ
      HQ.LandsOfIllusions
      HQ.Residence
    ]

    regionIds = (region.id() for region in regions)

    location = LOI.adventure.currentLocation()
    return unless location.region().id() in regionIds
    
    people = _.filter LOI.adventure.currentLocationThings(), (thing) => thing instanceof LOI.Character.Person
    characterId = LOI.characterId()

    scene = @options.parent

    for person in people when person._id isnt characterId
      do (person) =>
        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.TalkTo, person.avatar]
          action: =>
            scene._prepareScriptForPerson person
            @startScript()
