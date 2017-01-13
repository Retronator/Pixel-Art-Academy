LOI = LandsOfIllusions

class LOI.Adventure.Script.Helpers extends LOI.Adventure.Script.Helpers
  addItemToInventory: (options) ->
    LOI.adventure.gameState().player.inventory[options.item.id()] = options.state or {}
    LOI.adventure.gameState.updated()

  removeItemFromInventory: (options) ->
    delete LOI.adventure.gameState().player.inventory[options.item.id()]
    LOI.adventure.gameState.updated()

  pickUpItem: (options) ->
    console.log "Picking up item", options.item.id, "at location with state", options.location.state() if LOI.debug

    locationThings = options.location.state().things
    itemState = locationThings[options.item.id()]
    delete locationThings[options.item.id()]

    LOI.adventure.gameState().player.inventory[options.item.id()] = itemState
    LOI.adventure.gameState.updated()

  dropItem: (options) ->
    playerInventory = LOI.adventure.gameState().player.inventory
    itemState = playerInventory[options.item.id()]
    delete playerInventory[options.item.id()]

    @options.location.state().things[options.item.id()] = itemState
    LOI.adventure.gameState.updated()

  receiveItemFromActor: (options) ->
    console.log "Receiving item", options.item.id, "from", options.actor.id, "at location with state", options.location.state() if LOI.debug

    actor = options.location.state().things[options.actor.id()]
    itemState = actor.inventory[options.item.id()]
    delete actor.inventory[options.item.id()]

    LOI.adventure.gameState().player.inventory[options.item.id()] = itemState
    LOI.adventure.gameState.updated()

  giveItemToActor: (options) ->
    playerInventory = LOI.adventure.gameState().player.inventory
    itemState = playerInventory[options.item.id()]
    delete playerInventory[options.item.id()]

    actor = options.location.state().things[options.actor.id()]
    actor.inventory ?= {}
    actor.inventory[options.item.id()] = itemState
    LOI.adventure.gameState.updated()
