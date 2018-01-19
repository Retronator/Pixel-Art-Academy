LOI = LandsOfIllusions

# Executes simulation events on the server.
class LOI.Simulation.Server
  simulateGameState: (gameStateDocument) ->
    elapsedRealTime = Date.now() - gameStateDocument.lastUpdated.getTime()
    elapsedGameTime = LOI.Time.realTimeToSimulatedGameTimeDuration elapsedRealTime
    
    simulationEndGameTime = gameStateDocument.state.gameTime + elapsedGameTime
    
    # Keep processing events that happen before the end time.
    loop
      earliestEvent = _.first _.sortBy gameStateDocument.events, (event) => event.gameTime
      break if earliestEvent.gameTime > simulationEndGameTime

      # Move game time forward to this event in case process function relies on it.
      gameStateDocument.state.gameTime = earliestEvent.gameTime
      
      eventInstance = gameStateDocument.getEvent earliestEvent
      result = eventInstance.process()

      # Events other than stop events automatically succeed.
      result = true unless eventInstance instanceof LOI.Adventure.StopEvent
        
      if result
        # The event was successfully processed so remove it.
        gameStateDocument.removeEvent earliestEvent
        
      else
        # Event was not processed so we stop here.
        break

    # Move game time to end time, unless the blocking event was earlier.
    gameStateDocument.state.gameTime = simulationEndGameTime unless earliestEvent.gameTime < simulationEndGameTime

    # Save all game state updates to the server. 
    LOI.GameState.update gameStateDocument._id, gameStateDocument.state
