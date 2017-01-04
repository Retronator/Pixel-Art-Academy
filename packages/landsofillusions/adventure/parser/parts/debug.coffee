AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser extends LOI.Adventure.Parser
  parseDebug: (command) ->

    if command.has 'reset location'
      console.log "We are resetting location state." if LOI.debug

      state = @options.adventure.gameState()
      state.locations[@location.id()] = {}
      @options.adventure.gameState.updated()

      return true

    if command.has 'reset game state'
      console.log "We are resetting the whole game state." if LOI.debug

      state = @options.adventure.gameState()
      LOI.Adventure.resetGameState state
      @options.adventure.gameState.updated()

      return true

    if command.has 'reset tablet apps'
      console.log "We are resetting all apps on the tablet." if LOI.debug

      tablet = @options.adventure.inventory Retronator.HQ.Items.Tablet
      apps = tablet.state().apps

      apps[appId] = {} for appId, app of apps

      @options.adventure.gameState.updated()

      return true

    if command.has 'clean inventory'
      inventoryState = @options.adventure.gameState().player.inventory

      # Clear all the items for which the ID doesn't correspond to a thing.
      for itemId of inventoryState
        itemClass = LOI.Adventure.Thing.getClassForId itemId
        delete inventoryState[itemId] unless itemClass

      @options.adventure.gameState.updated()

    if command.has 'fullscreen'
      AM.Window.enterFullscreen()
