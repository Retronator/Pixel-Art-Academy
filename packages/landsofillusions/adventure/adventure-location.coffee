AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeCurrentLocation: ->
    # We store player's current location locally so that multiple people
    # can use the same user account and walk around independently.
    @currentLocationId = new ReactiveField null
    Artificial.Mummification.PersistentStorage.persist
      storageKey: 'LandsOfIllusions.Adventure.currentLocationId'
      field: @currentLocationId
      tracker: @

    # Instantiate current location. It depends only on the ID.
    # HACK: ComputedField triggers recomputation when called from events so we use ReactiveField + autorun manually.
    @currentLocation = new ReactiveField null
    @autorun (computation) =>
      # React to location ID changes.
      currentLocationId = @currentLocationId()

      Tracker.nonreactive =>
        @_currentLocation?.destroy()

        currentLocationClass = LOI.Adventure.Location.getClassForId currentLocationId

        # If we don't have a location set (or if it's not found), start at the default location.
        unless currentLocationClass
          console.warn "Location class not found, moving back to start.", currentLocationId if currentLocationId

          currentLocationClass = Retropolis.Spaceport.AirportTerminal.Terrace
          currentLocationId = currentLocationClass.id()
          @currentLocationId currentLocationId

        # Save current location to state. We don't really use it except until the next time we load the game.
        if state = @gameState()
          state.currentLocationId = currentLocationId
          @gameState.updated()

        console.log "Creating new location with ID", currentLocationClass.id() if LOI.debug

        # Create a non-reactive reference so we can refer to it later.
        @_currentLocation = new currentLocationClass
        
        @currentLocation @_currentLocation

    # Run logic on entering a new location.
    @autorun (computation) =>
      return unless location = @currentLocation()
      currentLocationClass = location.constructor

      # Wait for listeners to get instantiated as well.
      Tracker.afterFlush => Tracker.nonreactive =>
        # Query all the listeners if they need to perform any action on enter.
        listeners = LOI.adventure.currentListeners()

        # Exclude the listeners that are part of scenes that don't happen on this location.
        listeners = _.filter listeners, (listener) =>
          listenerScene = listener.options.parent if listener.options.parent instanceof LOI.Adventure.Scene
          return if listenerScene and listenerScene.constructor.location() isnt currentLocationClass

          true

        # Query the listeners and save the results for the interface to use as well.
        @locationOnEnterResponseResults = for listener in listeners
          enterResponse = new LOI.Parser.EnterResponse {currentLocationClass}

          listener.onEnter enterResponse

          {enterResponse, listener}

  goToLocation: (locationClassOrId) ->
    currentLocationClass = _.thingClass @currentLocationId()
    destinationLocationClass = _.thingClass locationClassOrId
    
    # Query all the listeners if they need to perform any action on exit.
    results = for listener in @currentListeners()
      exitResponse = new LOI.Parser.ExitResponse {currentLocationClass, destinationLocationClass}

      listener.onExitAttempt exitResponse

      {exitResponse, listener}

    # See if exit was prevented.
    for result in results
      return if result.exitResponse.wasExitPrevented()

    # Notify the listeners that exit will complete.
    for result in results
      result.listener.onExit result.exitResponse

    # Change location.
    @currentLocationId _.thingId locationClassOrId
