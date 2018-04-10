LOI = LandsOfIllusions
PAA = PixelArtAcademy
E1 = PixelArtAcademy.Season1.Episode1
HQ = Retronator.HQ
SF = SanFrancisco

Vocabulary = LOI.Parser.Vocabulary

class E1.PersonConversation extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.PersonConversation'

  @location: ->
    # Applies to all locations.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/scenes/personconversation.script'

  # Listener

  onCommand: (commandResponse) ->
    people = LOI.adventure.currentPeople()
    characterId = LOI.characterId()

    for person in people when person._id isnt characterId
      do (person) =>
        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.TalkTo, person.avatar]
          action: =>
            # Replace the person with target character.
            @script.setThings {person}

            @startScript()
