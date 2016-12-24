AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeCurrentLocation: ->
    # We store player's current location locally so that multiple people
    # can use the same user account and walk around independently.
    @currentLocationId = new ReactiveField null
    Artificial.Mummification.PersistentStorage.persist
      storageKey: "LandsOfIllusions.Adventure.currentLocationId"
      field: @currentLocationId
      tracker: @

    # If we don't have a locally stored location, start at the default location.
    unless @currentLocationId()
      if location.hostname is Meteor.settings.public.welcomeHostname
        @currentLocationId PixelArtAcademy.LandingPage.Locations.Retropolis.id()

      else
        @currentLocationId Retronator.HQ.Locations.Entrance.id()

    # Instantiate current location. It depends only on the ID.
    # HACK: ComputedField triggers recomputation when called from events so we use ReactiveField + autorun manually.
    @currentLocation = new ReactiveField null
    @autorun (computation) =>
      # React to location ID changes.
      currentLocationId = @currentLocationId()

      Tracker.nonreactive =>
        @_currentLocation?.destroy()

        currentLocationClass = LOI.Adventure.Location.getClassForId currentLocationId

        unless currentLocationClass
          console.error "Location class not found", currentLocationId
          return

        console.log "Creating new location with ID", currentLocationClass.id() if LOI.debug

        # Create a non-reactive reference so we can refer to it later.
        @_currentLocation = new currentLocationClass adventure: @

        # Reactively provide the state to the location.
        Tracker.autorun (computation) => 
          return unless state = @getLocationState currentLocationId
          console.log "Sending new state to location", currentLocationId, "game state:", @gameState(), "location state", state if LOI.debug

          @_currentLocation.state state

        @currentLocation @_currentLocation

  getLocationState: (locationClassOrId) ->
    return unless gameState = @gameState()

    locationId = _.thingId locationClassOrId
    locationClass = LOI.Adventure.Location.getClassForId locationId
    
    state = gameState.locations[locationId]

    # Initialize location state if this is first time at location or the location is at a new version.
    targetVersion = locationClass.version()
    unless state?.version is targetVersion
      console.log "Preparing to initialize location to new version", targetVersion if LOI.debug
      console.log "Location ID is", locationId, locationClass if LOI.debug

      existingState = state or {}
      console.log "Current state is", existingState if LOI.debug

      state = _.merge locationClass.initialState(), existingState, version: targetVersion

      gameState.locations[locationId] = state

      console.log "Initialized location", locationId, "with new state", state if LOI.debug

      Tracker.nonreactive => @gameState.updated()

    state
