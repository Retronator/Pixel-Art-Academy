AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser extends LOI.Adventure.Parser
  parseLookLocation: (command) ->
    Vocabulary = LOI.Adventure.Parser.Vocabulary

    wordsForVerb = @vocabulary.getWords Vocabulary.Keys.Verbs.Look

    console.log "We are searching for look verb words", wordsForVerb if LOI.debug

    if command.has wordsForVerb
      console.log "We have it! Reset interface to display initial description." if LOI.debug

      @options.adventure.interface.resetInterface?()
      return true
