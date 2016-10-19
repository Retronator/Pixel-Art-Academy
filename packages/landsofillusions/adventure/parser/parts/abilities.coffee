AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser extends LOI.Adventure.Parser
  parseAbilities: (command) ->
    # See if any of the words is a verb that one of the actors supports.
    for actor in @location.actors()
      continue unless actor.name

      # See if actor's name is targeted in the command.
      continue unless command.has actor.name

      # We indeed are targeted! Let's see if any of our action verbs is used.
      for ability in actor.abilities()
        if ability instanceof LOI.Adventure.Actor.Abilities.Action
          action = ability

          if command.has action.verb
            # Yes, we should do this action!!!"
            action.execute()
            return true
