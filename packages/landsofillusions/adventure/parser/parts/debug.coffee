AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Parser extends LOI.Adventure.Parser
  parseDebug: (command) ->

    if command.has 'reset location'
      console.log "We are resetting location state." if LOI.debug

      state = @options.adventure.gameState()
      state.locations[@location.id()] = @location.initialState()
      @options.adventure.gameState.updated()

      return true

    if command.has 'reset game state'
      console.log "We are resetting the whole game state." if LOI.debug

      state = @options.adventure.gameState()
      @options.adventure.initializeGameState state
      @options.adventure.gameState.updated()

      return true
