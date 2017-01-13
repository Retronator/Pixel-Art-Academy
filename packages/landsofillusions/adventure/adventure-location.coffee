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

          currentLocationClass = Retropolis.Spaceport.Locations.Terrace
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
