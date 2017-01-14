LOI = LandsOfIllusions

class LOI.Adventure.Ability
  constructor: ->
    # A thing field that is set from the owner thing.
    @thing = new ReactiveField null

  destroy: ->

  # Pass-through helper to access running scripts.
  currentScriptNodes: ->
    @thing()?.currentScriptNodes() or []
