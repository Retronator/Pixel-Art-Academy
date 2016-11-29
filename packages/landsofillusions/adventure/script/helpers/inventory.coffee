LOI = LandsOfIllusions

class LOI.Adventure.Script.Helpers extends LOI.Adventure.Script.Helpers
  addItemToInventory: (options) ->
    @adventure.gameState().player.inventory[options.item.id()] = options.state or {}
    @adventure.gameState.updated()

  removeItemFromInventory: (options) ->
    delete @adventure.gameState().player.inventory[options.item.id()]
    @adventure.gameState.updated()

  pickUpItem: (options) ->
    console.log "Picking up item", options.item.id, "at location with state", options.location.state() if LOI.debug
    itemState = options.location.state().things[options.item.id()]
    delete options.location.state().things[options.item.id()]
    @adventure.gameState().player.inventory[options.item.id()] = itemState
    @adventure.gameState.updated()

  dropItem: (options) ->
    itemState = @adventure.gameState().player.inventory[options.item.id()]
    delete @adventure.gameState().player.inventory[options.item.id()]
    @options.location.state().things[options.item.id()] = itemState
    @adventure.gameState.updated()
