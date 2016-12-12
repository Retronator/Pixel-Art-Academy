AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeInventory: ->
    # Create inventory.
    @inventory = new LOI.StateNode
      adventure: @

    # Reactively update inventory state.
    @autorun (computation) =>
      console.log "Setting updated inventory state to the inventory object.", @gameState()?.player.inventory if LOI.debug

      @inventory.updateState @gameState()?.player.inventory
