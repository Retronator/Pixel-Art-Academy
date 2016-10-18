LOI = LandsOfIllusions

class LOI.Adventure.Actor.Ability
  constructor: ->
    @actor = new ReactiveField null

  # Pass-through helper to access running scripts.
  currentScripts: ->
    @actor()?.currentScripts() or []
