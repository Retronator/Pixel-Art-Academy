AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser
  constructor: (@adventure) ->

  parse: (command) ->
    location = @adventure.currentLocation()

    words = _.map _.words(command), _.toLower

    # See if any of the words is a verb that one of the actors supports.
    for actor in location.actors()
      return unless actor.name

      # See if actor's name is targeted in the command.
      continue unless actor.name.toLowerCase() in words

      # We indeed are targeted! Let's see if any of our action verbs is used.
      for ability in actor.abilities()
        if ability instanceof LOI.Adventure.Actor.Abilities.Action
          action = ability

          if action.verb in words
            # Yes, we should do this action!!!"
            action.execute()
