LOI = LandsOfIllusions

# Executes simulation events on the server.
class LOI.Simulation.Server
  # Call to simulate all game states that have events pending for simulation.
  @simulateAllEvents: ->
    gameStates = LOI.GameState.documents.fetch
      nextSimulateTime: $lt: new Date()

    @simulateGameState gameState for gameState in gameStates

    # Return number of game states simulated.
    gameStates.length

  @simulateGameState: (gameStateDocument) ->
    # Nothing to do if no events are pending.
    return unless gameStateDocument.events.length

    # Calculate how much time has passed since game state was updated.
    elapsedRealTime = Date.now() - gameStateDocument.stateLastUpdatedAt.getTime()
    
    # If we wanted to simulate the game world since then, how much game time would pass?
    elapsedGameTime = LOI.Time.realTimeToSimulatedGameTimeDuration elapsedRealTime
    
    # What would be the game time now if we simulated for this duration?
    simulationEndGameTime = gameStateDocument.state.gameTime + elapsedGameTime
    
    # Keep processing events that happen before the end time.
    eventsProcessedCount = 0

    loop
      earliestEvent = _.first _.sortBy gameStateDocument.events, (event) => event.gameTime
      break if earliestEvent.gameTime > simulationEndGameTime

      # Move game time forward to this event in case process function relies on it.
      gameStateDocument.state.gameTime = earliestEvent.gameTime
      gameStateDocument.readOnlyState.simulatedGameTime = gameStateDocument.state.gameTime

      # Process the event. It will update the game state in place (read-only state and events, but not user state).
      eventInstance = gameStateDocument.getEvent earliestEvent
      result = eventInstance.process()

      eventsProcessedCount++

      # Events other than stop events automatically succeed.
      result = true unless eventInstance instanceof LOI.Adventure.StopEvent

      # If game time is past the stop event it also automatically passes.
      result = true if gameStateDocument.state.gameTime > earliestEvent.gameTime
        
      if result
        # The event was successfully processed so remove it.
        gameStateDocument.removeEventLocally earliestEvent

        # Stop if there are no more events.
        break unless gameStateDocument.events.length
        
      else
        # Event was not processed so we stop here.
        break

    # No need to update game state if no events were processed.
    return unless eventsProcessedCount

    # Move game time to end time, unless the blocking event was earlier.
    gameStateDocument.state.gameTime = simulationEndGameTime unless earliestEvent.gameTime < simulationEndGameTime

    # Simulated game time also matches the calculated game time. We need it written in the read-only state though,
    # since we can't trust the client state to preserve our correct value (race conditions and such).
    gameStateDocument.readOnlyState.simulatedGameTime = gameStateDocument.state.gameTime

    # Atomically update game state document, which will trigger nextSimulateTime calculation and if needed further
    # simulations (if any events not processed now would just get triggered in this time as we were updating the
    # state).
    LOI.GameState.documents.update gameStateDocument._id,
      $set:
        state: gameStateDocument.state
        stateLastUpdatedAt: new Date()
        readOnlyState: gameStateDocument.readOnlyState
        events: gameStateDocument.events

# Initialize on startup.
Document.startup ->
  # Simulate game state every 10 minutes.
  for minute in [5, 15, 25, 35, 45, 55]
    new Cron =>
      simulatedCount = LOI.Simulation.Server.simulateAllEvents()
      console.log "Scheduled simulation of events. #{simulatedCount} game states updated." if simulatedCount
    ,
      minute: minute
