LOI = LandsOfIllusions

class LOI.Adventure.Actor
  @initialize: (@options) ->
    LOI.Avatar.initialize @options?.avatar

  constructor: (@options) ->
    @avatar = new LOI.Avatar @options?.avatar

    @abilities = new ReactiveField []
    @director = new ReactiveField null

  addAbility: (abilityClass, params...) ->
    # Create the ability
    ability = new abilityClass params...

    # Create a two-way relationship and add the ability to the list to render it.
    ability.actor @
    @abilities @abilities().concat ability

  # Pass-through helper to access running scripts.
  currentScripts: ->
    @director()?.currentScripts() or []
