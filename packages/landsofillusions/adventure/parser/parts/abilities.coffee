AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser extends LOI.Adventure.Parser
  parseAbilities: (command) ->
    console.log "Checking if the command", command, "uses any of the things' abilities." if LOI.debug

    # See if we named any of the things.
    for thing in @_availableThings()
      name = thing.avatar.shortName()
      continue unless name

      console.log "We have a thing called", name if LOI.debug

      # See if thing's name is targeted in the command.
      continue unless command.has name

      console.log "And this thing was named! Checking ability verbs.", thing.abilities() if LOI.debug

      # We indeed are targeted! Let's see if any of our action verbs is used.
      for ability in thing.abilities()
        if ability instanceof LOI.Adventure.Ability.Action
          for verb in ability.verbs
            wordsForVerb = @vocabulary.getWords verb
  
            console.log "We are searching for ability words", wordsForVerb if LOI.debug

            if command.has wordsForVerb
              # Yes, we should do this action!!!"
              console.log "We have it! Executing action ..." if LOI.debug

              ability.execute()
              return true

      # If we have only one ability and the command was just the thing name, perform that ability.
      if (thing.abilities().length is 1) and command.is name
        thing.abilities()[0].execute()
