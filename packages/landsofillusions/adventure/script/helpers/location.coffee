LOI = LandsOfIllusions

class LOI.Adventure.Script.Helpers extends LOI.Adventure.Script.Helpers
  addItemToLocation: (options) ->
    @options.location.state()[options.item.id()] = options.state or {}
    @adventure.gameState.updated()

  removeItemFromLocation: (options) ->
    @adventure.gameState.updated()
