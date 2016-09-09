AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Actor.Ability extends AM.Component
  # Pass-through helper to access running scripts.
  currentScripts: ->
    @actor.currentScripts()
