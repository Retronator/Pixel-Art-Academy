LOI = LandsOfIllusions
Actor = LOI.Adventure.Actor

class Actor.Abilities.Action extends Actor.Ability
  constructor: (options) ->
    super

    @verb = options.verb.toLowerCase()
    @action = options.action

  execute: ->
    @action()
