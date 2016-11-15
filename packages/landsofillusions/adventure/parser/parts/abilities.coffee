AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser extends LOI.Adventure.Parser
  parseAbilities: (command) ->
    console.log "Checking if the command", command, "uses any of the things' abilities." if LOI.debug

    # See if any of the words is a verb that one of the actors supports.
    for thing in @location.things.values()
      name = thing.avatar.shortName()
      continue unless name

      console.log "We have a thing called", name if LOI.debug

      # See if actor's name is targeted in the command.
      continue unless command.has name

      console.log "And this item was named! Checking ability verbs.", thing.abilities() if LOI.debug

      # We indeed are targeted! Let's see if any of our action verbs is used.
      for ability in thing.abilities()
        if ability instanceof LOI.Adventure.Ability.Action
          action = ability

          for verb in action.verbs
            wordsForVerb = @vocabulary.getWords verb
  
            console.log "We are searching for ability words", wordsForVerb if LOI.debug

            if command.has wordsForVerb
              # Yes, we should do this action!!!"
              console.log "We have it! Executing action ..." if LOI.debug

              action.execute()
              return true
