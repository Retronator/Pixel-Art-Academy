AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Actor extends AM.Component
  @register 'LandsOfIllusions.Adventure.Actor'

  constructor: ->
    super

    @abilities = new ReactiveField []

  addAbility: (abilityClass, params...) ->
    # Create the ability
    ability = new abilityClass params...

    # Create a two-way relationship and add the ability to the list to render it.
    ability.actor = @
    @abilities @abilities().concat ability

  # Pass-through helper to access running scripts.
  currentScripts: ->
    @director.currentScripts()
