AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeLocation: ->
    # We store player's current location locally so that multiple people
    # can use the same user account and walk around independently.
    @currentLocationId = new ReactiveField null
    Artificial.Mummification.PersistentStorage.persist
      storageKey: 'LandsOfIllusions.Adventure.currentLocationId'
      field: @currentLocationId
      tracker: @

    # Instantiate current location. It depends only on the ID.
    @currentLocation = new ComputedField =>
      # React to location ID changes.
      currentLocationId = @currentLocationId()

      Tracker.nonreactive =>
        @_currentLocation?.destroy()

        # Clear any running scripts.
        LOI.adventure.director.stopAllScripts()

        currentLocationClass = LOI.Adventure.Location.getClassForId currentLocationId

        # If we don't have a location set (or if it's not found), start at the default location.
        unless currentLocationClass
          console.warn "Location class not found, moving back to start.", currentLocationId if currentLocationId

          switch @currentTimelineId()
            when PixelArtAcademy.TimelineIds.DareToDream
              currentLocationClass = Retropolis.Spaceport.AirportTerminal.Terrace

            when PixelArtAcademy.TimelineIds.RealLife
              currentLocationClass = Retronator.HQ.Cafe

            when PixelArtAcademy.TimelineIds.Construct
              currentLocationClass = LandsOfIllusions.Construct.Loading

          currentLocationId = currentLocationClass.id()
          @currentLocationId currentLocationId

        # Save current location to state. We don't really use it except until the next time we load the game.
        if state = @gameState()
          state.currentLocationId = currentLocationId
          @gameState.updated()

        console.log "Creating new location with ID", currentLocationClass.id() if LOI.debug

        # Create a non-reactive reference so we can refer to it later.
        @_currentLocation = new currentLocationClass
        
        @_currentLocation
    ,
      # Make sure to keep this computed field running.
      true

    @currentRegionId = new ComputedField =>
      @currentLocation().region().id()
    ,
      true

    @currentRegion = new ComputedField =>
      currentRegionClass = LOI.Adventure.Region.getClassForId @currentRegionId()

      # Check that the player can be in this region.
      playerHasPermission = currentRegionClass.playerHasPermission()

      # If it returns undefined it means it can't yet determine it.
      return unless playerHasPermission?

      # If we don't have permission, redirect to region's exit location.
      unless playerHasPermission
        console.warn "Player does not have permission to be in the region", currentRegionClass
        @currentLocationId _.thingId currentRegionClass.exitLocation()
        return

      # Everything is OK, instantiate the region.
      Tracker.nonreactive =>
        @_currentRegion?.destroy()
        @_currentRegion = new currentRegionClass
        @_currentRegion
    ,
      true

    # Run logic on entering a new location.
    @locationOnEnterResponseResults = new ReactiveField null
    
    @autorun (computation) =>
      # Clear previous enter responses.
      Tracker.nonreactive => @locationOnEnterResponseResults null

      return unless LOI.adventureInitialized()
      return unless location = @currentLocation()
      return unless location.ready()
      currentLocationClass = location.constructor

      # Wait for listeners to get instantiated as well.
      Tracker.afterFlush => Tracker.nonreactive =>
        # Wait for listeners to be ready.
        @autorun (computation) =>
          return unless listeners = LOI.adventure.currentListeners()

          # Exclude the listeners that are part of scenes that don't happen on this location.
          listeners = _.filter listeners, (listener) =>
            listenerScene = listener.options.parent if listener.options.parent instanceof LOI.Adventure.Scene

            # We want to include scenes that are present on all locations.
            return true unless listenerLocationClass = listenerScene?.location()

            # If the location is specified, it must match with current location.
            listenerLocationClass is currentLocationClass

          # Wait for all listeners to be ready.
          for listener in listeners
            return unless listener.ready()

          computation.stop()

          Tracker.nonreactive =>
            # Query all the listeners if they need to perform any action on
            # enter and save the results for the interface to use as well.
            responseResults = for listener in listeners
              enterResponse = new LOI.Parser.EnterResponse {currentLocationClass}

              listener.onEnter enterResponse

              {enterResponse, listener}

            @locationOnEnterResponseResults responseResults

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
