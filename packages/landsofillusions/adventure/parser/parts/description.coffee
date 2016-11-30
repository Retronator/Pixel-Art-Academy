AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser extends LOI.Adventure.Parser
  parseDescription: (command) ->
    Vocabulary = LOI.Adventure.Parser.Vocabulary

    console.log "Checking if the command", command, "is trying to get the description of any of the items." if LOI.debug

    # Go over things and see if we're naming any of them.
    for thing in @_availableThings()
      name = thing.avatar.shortName()
      continue unless name

      console.log "We have a thing called", name if LOI.debug

      # See if thing's name is targeted in the command.
      continue unless command.has name

      console.log "And this thing was named! Checking description verbs." if LOI.debug

      # We indeed are targeted! Let's see if any of the description verbs is used.
      for verb in [Vocabulary.Keys.Verbs.What, Vocabulary.Keys.Verbs.Look]
        wordsForVerb = @vocabulary.getWords verb

        console.log "We are searching for description verb words", wordsForVerb if LOI.debug

        if command.has wordsForVerb
          # Yes, we should output the descriptions.
          console.log "We have it! Display description." if LOI.debug

          @options.adventure.showDescription thing
          return true
