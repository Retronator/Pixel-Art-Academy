LOI = LandsOfIllusions
Ability = LOI.Adventure.Ability

class Ability.Action extends Ability
  constructor: (options) ->
    super

    @verbs = options.verbs or [options.verb]
    @action = options.action

  execute: ->
    @action()
